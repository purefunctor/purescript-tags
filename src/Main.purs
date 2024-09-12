module Main where

import Prelude

import ArgParse.Basic (ArgError, ArgParser)
import ArgParse.Basic as Arg
import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Set as Set
import Data.Traversable (for)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.Glob.Basic (expandGlobs)
import Node.Path as Path
import Node.Process as Process
import PursTags.Ctags as Ctags
import PursTags.Emacs as Emacs
import PursTags.Types (SourcePath(..), SourceString(..))

data TagsFormat = Etags | Ctags | Both

derive instance Eq TagsFormat

data Command
  = Generate { tagsFormat :: TagsFormat, useAbsolutePath :: Boolean, pursGlob :: Array String }

derive instance Eq Command

parser :: ArgParser Command
parser = Arg.flagHelp *> ado
  tagsFormat' <- tagsFormat
  useAbsolutePath' <- useAbsolutePath
  pursGlob' <- pursGlob
  in Generate
     { tagsFormat: tagsFormat'
     , useAbsolutePath: useAbsolutePath'
     , pursGlob: pursGlob'
     }
  where
  tagsFormat =
    Arg.choose "tags format"
      [ Arg.flag [ "--etags", "-e" ] "Generate Emacs-compatible tags."
          $> Etags
      , Arg.flag [ "--ctags", "-c" ] "Generate Vi-compatibile tags."
          $> Ctags
      , Arg.flag [ "--both", "-b" ] "Generate tags for both formats."
          $> Both
      ]
      # Arg.default Etags

  useAbsolutePath = Arg.flag [ "--absolute", "-a" ]
    "Generate tags with absolute source paths."
    # Arg.boolean
    # Arg.default false

  pursGlob = Arg.anyNotFlag "PURS_GLOB"
    "Globs for PureScript source files."
    # Arg.unfolded

main ∷ Effect Unit
main = do
  args <- Array.drop 2 <$> Process.argv
  workDir <- Process.cwd

  let
    command :: Either ArgError Command
    command = Arg.parseArgs
      "purstags"
      "A tool for generatings tags from source files."
      parser
      args

  case command of
    Left err -> do
      Console.log $ Arg.printArgError err
      case err of
        Arg.ArgError _ Arg.ShowHelp -> do
          Process.exit' 0
        Arg.ArgError _ (Arg.ShowInfo _) -> do
          Process.exit' 0
        _ -> do
          Process.exit' 1

    Right (Generate { tagsFormat, useAbsolutePath, pursGlob }) -> launchAff_ do
      fullSrcPaths <- Set.toUnfoldable <$> (expandGlobs workDir pursGlob)

      let
        srcPaths :: Array String
        srcPaths =
          if useAbsolutePath
          then fullSrcPaths
          else Path.relative workDir <$> fullSrcPaths

        generateEtags :: Aff Unit
        generateEtags = do
          let
            foldEtags = Array.intercalate "\n" <<< Array.catMaybes

          sections <- foldEtags <$> for srcPaths \srcPath -> do
            srcStr <- readTextFile UTF8 srcPath
            case Emacs.getSourceEtags (SourcePath srcPath) (SourceString srcStr) of
              Just etags -> do
                Just <$> Emacs.renderEtags (SourceString srcStr) etags
              _ -> do
                Console.error $ "Could not generate Emacs tags for " <> srcPath
                pure Nothing

          writeTextFile UTF8 (Path.concat [ workDir, "TAGS" ]) sections
          Console.log "Wrote Emacs 'TAGS' file."

        generateCtags :: Aff Unit
        generateCtags = do
          let
            foldCtags = Array.intercalate "\n" <<< Array.sort <<< join <<< Array.catMaybes

          entries <- foldCtags <$> for srcPaths \srcPath -> do
            srcStr <- readTextFile UTF8 srcPath
            case Ctags.getSourceCtags (SourcePath srcPath) (SourceString srcStr) of
              Just ctags -> do
                pure (Just $ Ctags.renderCtags ctags)
              _ -> do
                Console.error $ "Could not generate Vi tags for " <> srcPath
                pure Nothing

          writeTextFile UTF8 (Path.concat [ workDir, "tags" ]) entries
          Console.log "Wrote Vi 'tags' file."

      case tagsFormat of
        Etags ->
          generateEtags
        Ctags ->
          generateCtags
        Both -> do
          generateEtags
          generateCtags

      liftEffect $ Process.exit' 0

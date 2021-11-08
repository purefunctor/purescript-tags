module Main where

import Prelude

import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Traversable (for_)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile)
import Node.Glob.Basic (expandGlobs)
import Node.Process (argv, cwd)
import PursTags.Emacs (getSourceEtags, renderEtags)
import PursTags.Types (SourcePath(..), SourceString(..))

main ∷ Effect Unit
main = do
  workDir ← cwd
  srcGlobs ← Array.drop 2 <$> argv

  launchAff_ do
    srcPaths ← expandGlobs workDir srcGlobs

    for_ srcPaths \srcPath → do
      srcStr ← readTextFile UTF8 srcPath
      case getSourceEtags (SourcePath srcPath) (SourceString srcStr) of
        Just etags → do
          section ← renderEtags (SourceString srcStr) etags
          log section
        _ →
          pure unit

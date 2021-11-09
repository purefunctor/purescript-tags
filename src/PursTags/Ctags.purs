module PursTags.Ctags where

import Prelude

import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import PureScript.CST (RecoveredParserResult(..), parseModule)
import PureScript.CST.Types (Module(..), ModuleHeader(..), Name)
import PursTags.Common (getModuleEntries)
import PursTags.Types (CtagsSrcEntry(..), SourcePath(..), SourceString(..), unName)

getSourceCtags :: SourcePath -> SourceString -> Maybe (Array CtagsSrcEntry)
getSourceCtags srcPath (SourceString srcStr) =
  let
    nameToEntry :: forall n. Newtype n String => Name n -> CtagsSrcEntry
    nameToEntry = unName >>> \{ text, line } -> CtagsSrcEntry { text, line, srcPath }
  in
   case parseModule srcStr of
     ParseSucceeded m@(Module { header: ModuleHeader ({ name: moduleName }) }) ->
       let
         moduleEntry :: CtagsSrcEntry
         moduleEntry = nameToEntry moduleName

         entries :: Array CtagsSrcEntry
         entries = getModuleEntries nameToEntry m
       in
         pure $ Array.cons moduleEntry entries
     _ ->
       Nothing

renderCtags :: Array CtagsSrcEntry -> Array String
renderCtags = map \(CtagsSrcEntry { text, srcPath: (SourcePath srcPath'), line }) ->
  text <> "\t" <> srcPath' <> "\t" <> show (line + 1)

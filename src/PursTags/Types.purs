module PursTags.Types where

import Prelude

import Data.Newtype (class Newtype, unwrap)
import PureScript.CST.Types as CST

newtype EtagsSrcHeader = EtagsSrcHeader
  { srcPath ∷ SourcePath
  , entries ∷ Array EtagsSrcEntry
  }

derive instance Newtype EtagsSrcHeader _
derive newtype instance Show EtagsSrcHeader

newtype EtagsSrcEntry = EtagsSrcEntry
  { text ∷ String
  , line ∷ Int
  , column ∷ Int
  }

derive instance Newtype EtagsSrcEntry _
derive newtype instance Show EtagsSrcEntry

newtype SourcePath = SourcePath String

derive instance Newtype SourcePath _
derive newtype instance Eq SourcePath
derive newtype instance Ord SourcePath
derive newtype instance Show SourcePath

newtype SourceString = SourceString String

derive instance Newtype SourceString _
derive newtype instance Show SourceString

unName ∷ ∀ n. Newtype n String ⇒ CST.Name n → { text ∷ String, line ∷ Int, column ∷ Int }
unName (CST.Name { name: text, token: { range: { start: { line, column } } } }) =
  { text: unwrap text
  , line
  , column
  }

newtype CtagsSrcEntry = CtagsSrcEntry
  { text :: String
  , line :: Int
  , srcPath :: SourcePath
  }

derive instance Newtype CtagsSrcEntry _
derive newtype instance Eq CtagsSrcEntry
derive newtype instance Ord CtagsSrcEntry
derive newtype instance Show CtagsSrcEntry

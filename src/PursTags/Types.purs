module PursTags.Types where

import Prelude

import Data.Newtype (class Newtype, unwrap)
import PureScript.CST.Types as CST
import Safe.Coerce (coerce)

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

nameToEntry ∷ ∀ n. Newtype n String ⇒ CST.Name n → EtagsSrcEntry
nameToEntry = (coerce ∷ (CST.Name n → _) → (CST.Name n → _)) unName

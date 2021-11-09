module PursTags.Emacs where

import Prelude

import Data.Array as Array
import Data.ArrayBuffer.Types (Uint8Array)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.String.CodePoints as SCP
import Effect.Class (class MonadEffect, liftEffect)
import PureScript.CST (RecoveredParserResult(..), parseModule)
import PureScript.CST.Types (Module(..), ModuleHeader(..), Name)
import PursTags.Common (getModuleEntries)
import PursTags.Foreign (unsafeByteOffsetBeforeLine, unsafeGetByteLength, unsafeGetLineStr)
import PursTags.Types
  ( EtagsSrcEntry(..)
  , EtagsSrcHeader(..)
  , SourcePath(..)
  , SourceString(..)
  , unName
  )
import Safe.Coerce (coerce)
import Web.Encoding.TextEncoder as TextEncoder

getSourceEtags ∷ SourcePath → SourceString → Maybe EtagsSrcHeader
getSourceEtags srcPath (SourceString srcStr) =
  let
    nameToEntry ∷ ∀ n. Newtype n String ⇒ Name n → EtagsSrcEntry
    nameToEntry = (coerce ∷ (Name n → _) → (Name n → _)) unName
  in
    case parseModule srcStr of
      ParseSucceeded m@(Module { header: ModuleHeader ({ name: moduleName }) }) →
        let
          moduleEntry :: EtagsSrcEntry
          moduleEntry = nameToEntry moduleName

          entries :: Array EtagsSrcEntry
          entries = Array.cons moduleEntry (getModuleEntries nameToEntry m)
        in
          pure $ EtagsSrcHeader
            { srcPath
            , entries
            }

      _ → Nothing

renderEtags ∷ ∀ m. MonadEffect m ⇒ SourceString → EtagsSrcHeader → m String
renderEtags (SourceString srcStr) (EtagsSrcHeader { srcPath, entries }) = do
  encoder ← liftEffect TextEncoder.new

  let
    encode ∷ String → Uint8Array
    encode = flip TextEncoder.encode encoder

    srcBuf ∷ Uint8Array
    srcBuf = encode srcStr

    body ∷ String
    body = Array.intercalate "\n" $ entries <#> \(EtagsSrcEntry { text, line, column }) →
      let
        lineStr ∷ String
        lineStr = unsafeGetLineStr srcStr line

        -- Take the byte offset before a specified line.
        preLineOffset ∷ Int
        preLineOffset = unsafeByteOffsetBeforeLine srcBuf line

        -- Take the byte offset needed to get to the column.
        lineOffset ∷ Int
        lineOffset = unsafeGetByteLength (encode (SCP.take (column + 1) lineStr))

        offset ∷ Int
        offset = preLineOffset + lineOffset
      in
        lineStr <> "\x7f" <> text <> "\x01" <> show (line + 1) <> "," <> show offset

    bodyBytes ∷ Int
    bodyBytes = unsafeGetByteLength (TextEncoder.encode body encoder)

    header ∷ String
    header = coerce srcPath <> "," <> show bodyBytes

  pure $ "\x0c" <> "\n" <> header <> "\n" <> body

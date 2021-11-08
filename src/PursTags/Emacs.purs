module PursTags.Emacs where

import Prelude

import Data.Array as Array
import Data.Array.NonEmpty as NEA
import Data.ArrayBuffer.Types (Uint8Array)
import Data.Maybe (Maybe(..))
import Data.String.CodePoints as SCP
import Data.Tuple (Tuple(..), snd)
import Effect.Class (class MonadEffect, liftEffect)
import PureScript.CST (RecoveredParserResult(..), parseModule)
import PureScript.CST.Traversal (defaultMonoidalVisitor, foldMapModule)
import PureScript.CST.Types (DataCtor(..), Declaration(..), FixityOp(..), Foreign(..), Labeled(..), Module, Separated(..))
import PursTags.Foreign (unsafeByteOffsetBeforeLine, unsafeGetByteLength, unsafeGetLineStr)
import PursTags.Types (EtagsSrcEntry(..), EtagsSrcHeader(..), SourcePath(..), SourceString(..), nameToEntry)
import Safe.Coerce (coerce)
import Web.Encoding.TextEncoder as TextEncoder

getDeclarationEntries ∷ Declaration Void → Array EtagsSrcEntry
getDeclarationEntries = case _ of
  DeclData { name: dataName } maybeCtors →
    let
      dataEntry ∷ EtagsSrcEntry
      dataEntry = nameToEntry dataName

      ctorEntries ∷ Array EtagsSrcEntry
      ctorEntries = case maybeCtors of
        Just (Tuple _ (Separated { head: (DataCtor { name: headName }), tail })) →
          let
            headEntry ∷ EtagsSrcEntry
            headEntry = nameToEntry headName

            tailEntries ∷ Array EtagsSrcEntry
            tailEntries = tail <#> snd >>> \(DataCtor { name: tailName }) → nameToEntry tailName
          in
            Array.cons headEntry tailEntries

        _ → mempty

    in
      Array.cons dataEntry ctorEntries

  DeclType { name: typeName } _ _ →
    [ nameToEntry typeName ]

  DeclNewtype { name: newtypeName } _ ctorName _ →
    [ nameToEntry newtypeName, nameToEntry ctorName ]

  DeclClass { name: className } maybeMembers →
    let
      classEntry ∷ EtagsSrcEntry
      classEntry = nameToEntry className

      memberEntries ∷ Array EtagsSrcEntry
      memberEntries = case maybeMembers of
        Just (Tuple _ members) → NEA.toArray $
          members <#> \(Labeled { label: memberName }) →
            nameToEntry memberName
        _ →
          mempty
    in
      Array.cons classEntry memberEntries

  DeclValue { name: valueName } →
    [ nameToEntry valueName ]

  DeclForeign _ _ innerForeign → case innerForeign of

    ForeignValue (Labeled { label: valueName }) →
      [ nameToEntry valueName ]

    ForeignData _ (Labeled { label: dataName }) →
      [ nameToEntry dataName ]

    ForeignKind _ kindName →
      [ nameToEntry kindName ]

  DeclFixity { operator } → case operator of

    FixityValue _ _ operatorName →
      [ nameToEntry operatorName ]

    FixityType _ _ _ operatorName →
      [ nameToEntry operatorName ]

  _ → mempty

getModuleEntries ∷ Module Void → Array EtagsSrcEntry
getModuleEntries = foldMapModule $ defaultMonoidalVisitor
  { onDecl = getDeclarationEntries
  }

getSourceEtags ∷ SourcePath → SourceString → Maybe EtagsSrcHeader
getSourceEtags srcPath (SourceString srcStr) =
  case parseModule srcStr of
    ParseSucceeded m →
      pure $ EtagsSrcHeader
        { srcPath
        , entries: getModuleEntries m
        }

    _ → Nothing

renderEtags ∷ ∀ m. MonadEffect m ⇒ SourceString → EtagsSrcHeader → m String
renderEtags (SourceString srcStr) (EtagsSrcHeader { srcPath, entries }) = do
  encoder ← liftEffect TextEncoder.new

  let
    encode = flip TextEncoder.encode encoder

    srcBuf ∷ Uint8Array
    srcBuf = encode srcStr

    body ∷ String
    body = Array.intercalate "\n" $ entries <#> \(EtagsSrcEntry { text, line, column }) →
      let
        lineStr ∷ String
        lineStr = unsafeGetLineStr srcStr line

        -- Take the byte offset before a specified line.
        preLineOffset :: Int
        preLineOffset = unsafeByteOffsetBeforeLine srcBuf line

        -- Take the byte offset needed to get to the column.
        lineOffset :: Int
        lineOffset = unsafeGetByteLength (encode (SCP.take (column + 1) lineStr))

        offset :: Int
        offset = preLineOffset + lineOffset
      in
        lineStr <> "\x7f" <> text <> "\x01" <> show (line + 1) <> "," <> show offset

    bodyBytes ∷ Int
    bodyBytes = unsafeGetByteLength (TextEncoder.encode body encoder)

    header ∷ String
    header = coerce srcPath <> "," <> show bodyBytes

  pure $ "\x0c" <> "\n" <> header <> "\n" <> body

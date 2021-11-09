module PursTags.Common where

import Prelude

import Data.Array as Array
import Data.Array.NonEmpty as NEA
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Tuple (Tuple(..), snd)
import PureScript.CST.Traversal (foldMapModule, defaultMonoidalVisitor)
import PureScript.CST.Types
  ( DataCtor(..)
  , Declaration(..)
  , FixityOp(..)
  , Foreign(..)
  , Labeled(..)
  , Name
  , Module
  , Separated(..)
  )

getDeclarationEntries ∷ ∀ e. (∀ n. Newtype n String ⇒ Name n → e) → Declaration Void → Array e
getDeclarationEntries nameToEntry  = case _ of
  DeclData { name: dataName } maybeCtors →
    let
      dataEntry ∷ e
      dataEntry = nameToEntry dataName

      ctorEntries ∷ Array e
      ctorEntries = case maybeCtors of
        Just (Tuple _ (Separated { head: (DataCtor { name: headName }), tail })) →
          let
            headEntry ∷ e
            headEntry = nameToEntry headName

            tailEntries ∷ Array e
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
      classEntry ∷ e
      classEntry = nameToEntry className

      memberEntries ∷ Array e
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

getModuleEntries ∷ ∀ e. (∀ n. Newtype n String ⇒ Name n → e) → Module Void → Array e
getModuleEntries nameToEntry = foldMapModule $ defaultMonoidalVisitor
  { onDecl = getDeclarationEntries nameToEntry
  }

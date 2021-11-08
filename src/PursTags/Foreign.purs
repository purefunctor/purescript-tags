module PursTags.Foreign where

import Data.ArrayBuffer.Types (Uint8Array)

foreign import unsafeByteOffsetBeforeLine ∷ Uint8Array -> Int -> Int

foreign import unsafeGetByteLength ∷ Uint8Array → Int

foreign import unsafeGetLineStr ∷ String → Int → String

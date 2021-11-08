module PursTags.Foreign where

import Data.ArrayBuffer.Types (Uint8Array)
import Data.Function.Uncurried (Fn3, runFn3)

foreign import unsafeComputeByteOffsetJs ∷ Fn3 Uint8Array Int Int Int

unsafeComputeByteOffset ∷ Uint8Array → Int → Int → Int
unsafeComputeByteOffset = runFn3 unsafeComputeByteOffsetJs

foreign import unsafeGetByteLength ∷ String → Int

foreign import unsafeGetLineStr ∷ String → Int → String

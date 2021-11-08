{ name = "purstags"
, dependencies =
  [ "aff"
  , "arraybuffer-types"
  , "arrays"
  , "console"
  , "effect"
  , "foldable-traversable"
  , "functions"
  , "language-cst-parser"
  , "maybe"
  , "newtype"
  , "node-buffer"
  , "node-fs-aff"
  , "node-glob-basic"
  , "node-process"
  , "prelude"
  , "safe-coerce"
  , "tuples"
  , "web-encoding"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
, license = "BSD-3-Clause"
, repository = "https://github.com/PureFunctor/purescript-tags.git"
}

let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.15-20240909/packages.dhall
        sha256:3b81bf89b8644c218274383c860cd1dbf350637b4f3ebe5d0aceba96bd020732

let overrides = {=}

let additions =
      { language-cst-parser =
        { dependencies =
          [ "arrays"
          , "const"
          , "control"
          , "effect"
          , "either"
          , "foldable-traversable"
          , "free"
          , "functors"
          , "identity"
          , "integers"
          , "lazy"
          , "lists"
          , "maybe"
          , "newtype"
          , "numbers"
          , "ordered-collections"
          , "partial"
          , "prelude"
          , "st"
          , "strings"
          , "transformers"
          , "tuples"
          , "typelevel-prelude"
          , "unfoldable"
          , "unsafe-coerce"
          ]
        , repo =
            "https://github.com/natefaubion/purescript-language-cst-parser.git"
        , version = "v0.9.3"
        }
      , node-glob-basic =
        { dependencies =
          [ "aff"
          , "console"
          , "effect"
          , "lists"
          , "maybe"
          , "node-fs"
          , "node-path"
          , "node-process"
          , "ordered-collections"
          , "strings"
          ]
        , repo = "https://github.com/natefaubion/purescript-node-glob-basic.git"
        , version = "v1.2.2"
        }
      , argparse-basic =
        { dependencies =
          [ "arrays"
          , "console"
          , "debug"
          , "effect"
          , "either"
          , "foldable-traversable"
          , "free"
          , "lists"
          , "maybe"
          , "node-process"
          , "psci-support"
          , "record"
          , "strings"
          , "transformers"
          ]
        , repo = "https://github.com/natefaubion/purescript-argparse-basic.git"
        , version = "v1.0.0"
        }
      }

in  upstream // overrides // additions

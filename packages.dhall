let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.14.4-20211030/packages.dhall
        sha256:5cd7c5696feea3d3f84505d311348b9e90a76c4ce3684930a0ff29606d2d816c

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
          , "node-fs-aff"
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

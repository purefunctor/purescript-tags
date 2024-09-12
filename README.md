# purescript-tags

A command line tool for generating Emacs tags for PureScript code
independent from the \`docs\` component of the PureScript compiler.
Instead, this project makes use of the
[language-cst-parser](https://github.com/natefaubion/purecript-language-cst-parser)
package to parse source files into their CST representation and into
Emacs tags.

## Usage

From the root of the project to create tags for:
```bash
node ~/projects/purescript-tags/dist/index.js -a -e "src/**/*.purs"
```
## Notes

To navigate to qualified tags you may need in your `.emacs` file:

```lisp
(modify-syntax-entry ?. "." purescript-mode-syntax-table)
```

([source](https://discourse.purescript.org/t/emacs-lsp-mode-with-purescript-language-server/1077/3))

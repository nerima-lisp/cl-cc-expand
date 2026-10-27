# Changelog

## Expander head table export

The `cl-cc/expand` facade now exports `*expander-head-table*`, which the
compiler binds while compiling forms so `compiler-macroexpand-all` can dispatch
form-expansion handlers.

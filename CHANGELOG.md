# Changelog

## Expander facade exports

The `cl-cc/expand` facade exports `*expander-head-table*`, which the compiler
binds while compiling forms so `compiler-macroexpand-all` can dispatch
form-expansion handlers. It also exports `*%active-restarts*` from
`cl-cc/expand/conditions`, so callers can bind the registry referenced by
restart macro expansions.

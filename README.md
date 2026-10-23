# cl-cc-expand

Macro expansion subsystem for the
[cl-cc](https://github.com/nerima-lisp/cl-cc) Common Lisp compiler: the macro
environment and `defmacro` machinery, `our-macroexpand-1`/`our-macroexpand`/
`our-macroexpand-all`, lambda-list parsing and destructuring, the compiler
macro expander (`defstruct`, `setf` places, typed lambda lists,
`deftransform`), and the `LOOP`/`DO`/`CASE`/`TYPECASE` control-flow macros.
The public expansion API is exported from the `cl-cc/expand` package.
The package also exports nine names used by the monorepo's runtime
integration: `rt-use-package`, `add-package-local-nickname`,
`%record-declaim-inline-clause`, `%record-declaim-optimize-clause`,
`%record-declaim-type-clause`, `%record-declaim-ftype-clause`,
`%record-declaim-special-clause`, `*macroexpand-step-cache*`, and
`*macroexpand-all-cache*`.

## Usage

```lisp
(asdf:load-system "cl-cc-expand")

(cl-cc/expand:our-macroexpand-1 '(when x (print x)))
(cl-cc/expand:compiler-macroexpand-all '(dolist (x list) (print x)))
```

## Pin in a consuming flake

```nix
# flake.nix
inputs.cl-cc-expand = {
  url = "github:nerima-lisp/cl-cc-expand/v0.1.1";
  flake = false;
};
```

This input pins the source tree. The consuming build must add it to
`CL_SOURCE_REGISTRY` so ASDF can find `cl-cc-expand`. Consumers in this org
must pin a release tag rather than follow the default branch.

## Development

This flake declares outputs only for x86_64-linux; run these commands from an x86_64 Linux environment.

```sh
nix develop      # SBCL with CL_SOURCE_REGISTRY already set
nix run .#test    # run the test suite
nix flake check   # tests + orphan check + formatting + paredit lint, the same gate CI uses
nix fmt           # format Nix sources (treefmt)
```

The `orphan-tests` check fails when a Lisp file under `t/` is not registered in
the test system's ASDF component list.
The ASDF `test-op` signals when cl-weave reports test failures, and the
`nix run .#test` entrypoint exits nonzero when that operation fails.

Tests live in `t/` and run under
[cl-weave](https://github.com/nerima-lisp/cl-weave), the org's test
framework. `t/package.lisp` maps the suite's `deftest` and `assert-*` forms
onto cl-weave's `it-sequential` and `expect` forms.

## Contributing

See the org-wide [CONTRIBUTING](https://github.com/nerima-lisp/.github/blob/main/CONTRIBUTING.md)
guide and the [package standard](https://github.com/nerima-lisp/.github/blob/main/PACKAGE_STANDARD.md).

## Support

See [SUPPORT](https://github.com/nerima-lisp/.github/blob/main/SUPPORT.md).

## License

MIT. See [LICENSE](LICENSE).

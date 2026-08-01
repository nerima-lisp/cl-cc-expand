# cl-cc-expand

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Macro expansion subsystem for the
[cl-cc](https://github.com/nerima-lisp/cl-cc) Common Lisp compiler: the macro
environment and `defmacro` machinery, `our-macroexpand-1`/`our-macroexpand`/
`our-macroexpand-all`, lambda-list parsing and destructuring, the compiler
macro expander (`defstruct`, `setf` places, typed lambda lists,
`deftransform`), and the `LOOP`/`DO`/`CASE`/`TYPECASE` control-flow macros.
Everything is exported from the `cl-cc/expand` package.

## Why this one was safe to extract

A 2026-08-01 audit (`docs/notes/repo-split-design.md` §10-7/§11 in the
monorepo) found that `cl-cc/expand`'s own ASDF dependencies
([`cl-cc-bootstrap`](https://github.com/nerima-lisp/cl-cc-bootstrap),
[`cl-cc-type`](https://github.com/nerima-lisp/cl-cc-type),
[`cl-cc-vm`](https://github.com/nerima-lisp/cl-cc-vm)) were all already
external, making `expand` a clean leaf dependency-wise. A fourth,
[`cl-host-kit`](https://github.com/nerima-lisp/cl-host-kit), was added by the
2026-08-01 org-wide `uiop`->`cl-host-kit` migration; it supplies the single
`host-kit:getenv` call that reads `$CLCC_TARGET_BACKEND`. Three files
*outside* `packages/expand` reached into `cl-cc/expand::` internal
(non-exported) symbols directly: `packages/selfhost`'s host-bridge
registration table, `packages/stdlib`'s self-hosted `PROCLAIM` source
string, and `packages/testing-framework`'s per-test cache-clearing fixture.
A decoupling commit in the monorepo exported the eight symbols those three
call sites needed (`rt-use-package`, `add-package-local-nickname`, the five
`%record-declaim-*-clause` functions, and `*macroexpand-step-cache*`/
`*macroexpand-all-cache*`) before this extraction, so none of that in-tree
code reaches past `cl-cc/expand`'s public interface anymore.

## Usage

```lisp
(asdf:load-system "cl-cc-expand")

(cl-cc/expand:our-macroexpand-1 '(when x (print x)))
(cl-cc/expand:compiler-macroexpand-all '(dolist (x list) (print x)))
```

## A note on `src/match.lisp` and two orphan test files

`src/match.lisp` (the `MATCH` structural-pattern-matching macro, FR-779/780)
ships in this repository but is deliberately **not** listed in
`cl-cc-expand.asd`'s `:components`, and `MATCH` is not in `cl-cc/expand`'s
`:export` list. It was already dead/unwired in the monorepo before this
extraction — absent from `packages/expand/cl-cc-expand.asd`'s own
`:components` there too. This extraction preserves that status quo rather
than silently reviving or silently deleting it, the same "double-definition
trap" class of carried-forward dead code documented for other packages in
this org (see `cl-cc-cps`'s README for the precedent).

The corresponding orphan test files — `t/match-test.lisp` (ported from
`packages/expand/tests/match-tests.lisp`) and `t/macros-keyword-opt-test.lisp`
(ported from `packages/expand/tests/macros-keyword-opt-tests.lisp`, which
calls `CL-CC/EXPAND:KEYWORD-OPTIMIZE-CALL` — a symbol that does not exist
anywhere in this package's source, monorepo or here) — are carried the same
way: shipped, but not listed in `cl-cc-expand/test`'s `:components`. Neither
was wired into the monorepo's own `cl-cc.asd` "expand-tests" module either.

## Install

```nix
# flake.nix
inputs.cl-cc-expand = {
  url = "github:nerima-lisp/cl-cc-expand/v0.1.0";
  flake = false;
};
```

Note the pinned tag. Consumers inside this org must pin a release tag rather
than follow the default branch.

## Development

```sh
nix develop      # SBCL with CL_SOURCE_REGISTRY already set
nix run .#test    # run the test suite
nix flake check   # tests + formatting + paredit lint, the same gate CI uses
nix fmt           # format Nix sources (treefmt)
```

Tests live in `t/` and run under
[cl-weave](https://github.com/nerima-lisp/cl-weave), the org's test
framework. `t/package.lisp` carries a small compatibility shim
(`deftest`/`deftest-each`/`assert-*`) re-expressed on top of cl-weave's
`it-sequential`/`expect`, so the ~86 wired test files ported from the
monorepo's own `deftest`-based suite needed only an `in-package` change
each — the same shim shape
[`cl-cc-type`](https://github.com/nerima-lisp/cl-cc-type) uses for its own
(larger) monorepo-`deftest` suite.

## Contributing

See the org-wide [CONTRIBUTING](https://github.com/nerima-lisp/.github/blob/main/CONTRIBUTING.md)
guide and the [package standard](https://github.com/nerima-lisp/.github/blob/main/PACKAGE_STANDARD.md).

## Support

See [SUPPORT](https://github.com/nerima-lisp/.github/blob/main/SUPPORT.md).

## License

MIT. See [LICENSE](LICENSE).

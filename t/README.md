`cl-cc-expand/test` tests macro expansion and the LOOP parser and emitters. Its ASDF system depends on `cl-cc-expand` and `cl-weave`; it does not load the `run-string` evaluator. The separate repository `nerima-lisp/cl-cc` defines `cl-cc-integration-suite` in `packages/testing-framework/src/framework.lisp` and registers `cl-cc/test` components in `cl-cc.asd`; compiled-program tests belong there.

Commit `cf5a113` is the pre-removal baseline: the deleted test files existed on disk there but were not ASDF components of `cl-cc-expand/test`. The basis column describes those baseline cases; retained-coverage paths point to the current tree.

Classification `a` means equivalent in-scope cases remain registered in the current `cl-cc-expand/test` ASDF system. Classification `b` means the removed path is outside that test system's registered scope: test cases need the umbrella runtime harness or reference an API or diagnostic type not implemented in this repository. For the source path `src/match.lisp`, `b` means it was excluded from production ASDF components and did not define the tested warning types. A mixed `a + b` row identifies both portions. The table includes `src/match.lisp` because it was deleted in the same cleanup; it is a source file, not a test file.

| Removed path | Category | Basis |
| --- | --- | --- |
| `t/loop-macro-test.lisp` | a + b | Eight expansion cases remain in `t/loop-macro-expansion-test.lisp`; runtime cases need the integration suite. |
| `t/loop-macro-advanced-test.lisp` | b | Runtime cases call `check-loop-equal` and `check-loop-length`, which evaluate through `run-string`. |
| `t/loop-macro-runtime-test.lisp` | b | Runtime-result cases use `run-string`. |
| `t/loop-macro-runtime-clauses-test.lisp` | a + b | REPEAT and WITH expansion cases remain in `t/loop-macro-expansion-clauses-test.lisp`; the rest need the integration suite. |
| `t/loop-macro-runtime-edge-test.lisp` | a + b | Three malformed-clause checks remain in `t/loop-macro-expansion-errors-test.lisp`; the rest need the integration suite. |
| `t/loop-macro-runtime-ext-test.lisp` | b | Runtime tests for LOOP synonyms such as COLLECTING/COLLECT and SUMMING/SUM, plus edges such as unbounded FROM with WHILE. |
| `t/fr-555-copy-structure-test.lisp` | b | COPY-STRUCTURE and DEFSTRUCT runtime results need the integration suite. |
| `t/macros-sequence-fold-test.lisp` | b | Sequence-operation runtime results need the integration suite. |
| `t/macros-keyword-opt-test.lisp` | b | Calls the undefined `cl-cc/expand:keyword-optimize-call`. |
| `t/match-test.lisp` | b | Expects `cl-cc/expand:match-exhaustiveness-warning` and `cl-cc/expand:match-unreachable-pattern-warning`; the test system does not load `src/match.lisp`. |
| `src/match.lisp` | b | At baseline commit `cf5a113`, it was excluded from production ASDF components and defined only an isolated MATCH macro, not either warning type. |

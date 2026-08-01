;;;; cl-cc-expand.asd — macro expansion subsystem for the cl-cc compiler.
;;;;
;;;; Extracted from the cl-cc monorepo (docs/notes/repo-split-design.md
;;;; §10-7, 2026-08-01 audit): cl-cc-expand's own ASDF deps
;;;; (cl-cc-bootstrap, cl-cc-type, cl-cc-vm) were already external, making
;;;; it a clean leaf dependency-wise. Three monorepo files reached into
;;;; cl-cc/expand:: internals directly (packages/selfhost's host-bridge
;;;; table, packages/stdlib's self-hosted PROCLAIM source string, and
;;;; packages/testing-framework's cache-clearing fixture); those eight
;;;; symbols were exported from cl-cc/expand in the decoupling commit that
;;;; preceded this extraction, so none of that in-tree code reaches past
;;;; the package's public interface anymore.
;;;;
;;;; NOTE on src/match.lisp: this file ships in the repository but is
;;;; deliberately NOT listed in :components below, exactly as
;;;; cl-cc-cps carries three unwired source files forward from the
;;;; monorepo. match.lisp was already dead/unwired in the monorepo before
;;;; this extraction (absent from packages/expand/cl-cc-expand.asd's own
;;;; :components, and MATCH is not in cl-cc/expand's :export list); this
;;;; extraction preserves that status quo rather than silently reviving or
;;;; silently deleting it. The matching orphan test file (t/match-test.lisp,
;;;; ported from packages/expand/tests/match-tests.lisp) is carried the same
;;;; way, plus t/macros-keyword-opt-test.lisp (ported from
;;;; packages/expand/tests/macros-keyword-opt-tests.lisp), which calls
;;;; CL-CC/EXPAND:KEYWORD-OPTIMIZE-CALL — a symbol that does not exist
;;;; anywhere in this package's source, monorepo or here. Both were already
;;;; absent from the monorepo's own cl-cc.asd "expand-tests" module (the
;;;; wired test list this extraction otherwise ported wholesale); neither
;;;; is listed in "cl-cc-expand/test" below.
;;;;
;;;; The runtime macro tests are likewise intentionally excluded below.
;;;; They exercise the complete compiler execution pipeline through the
;;;; monorepo's run-string helper, rather than cl-cc-expand in isolation;
;;;; parent-project integration tests retain that coverage.
;;;;
;;;; Both systems live in this one file; there is no separate
;;;; cl-cc-expand-test.asd. System names are written as STRINGS rather than
;;;; #:symbols or :keywords, so that reading this file does not depend on the
;;;; reader's current package state.

(in-package #:asdf-user)

(defsystem "cl-cc-expand"
  :description "Macro expansion subsystem: macro-env, defmacro, macroexpand, lambda-list, LOOP"
  :author "takeokunn <bararararatty@gmail.com>"
  :maintainer "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :version "0.1.0"
  :homepage "https://github.com/nerima-lisp/cl-cc-expand"
  :bug-tracker "https://github.com/nerima-lisp/cl-cc-expand/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-cc-expand.git")
  :depends-on ("cl-cc-bootstrap" "cl-cc-type" "cl-cc-vm")
  :pathname "src"
  :serial t
  :components
  ((:file "package")
   (:file "macro-lambda-list")   ; shared lambda-list parsing + destructuring helpers
   (:file "macro")
   (:file "macro-expansion")     ; macroexpand, quasiquote, our-defmacro, VM hooks
   (:file "syntax-rules")        ; core: macro-env, defmacro machinery, macroexpansion
   (:file "macros-basic")        ; bootstrap: check-type/setf/list + value helpers
   (:file "macros-control-flow") ; bootstrap control-flow macros (when/unless/cond/do*)
   (:file "macros-control-flow-case") ; case/typecase macro expansion
   (:file "macros-mutation")     ; push/pop/incf/decf split from stdlib
   (:file "loop-data")           ; LOOP: grammar tables — the "Prolog database"
   (:file "loop-parser-for")     ; LOOP: token predicates, CPS utils, FOR sub-parsers
   (:file "loop-parser")         ; LOOP: CPS token parser → IR plist
   (:file "loop-emitters")       ; LOOP: registration macros + accumulation emitters
   (:file "loop-iter-emitters")  ; LOOP: iteration + condition emitters
   (:file "loop")                ; LOOP: generator — assembles tagbody from IR
   (:file "macros-setops")       ; list/set operations split from stdlib
   (:file "macros-list-utils")   ; ordering and list utility helpers
   (:file "macros-restarts")     ; restart/condition protocol split from stdlib
   (:file "macros-introspection") ; equalp and introspection helpers
   (:file "macros-iterator")      ; FR-839 iterator protocol
   (:file "macros-stdlib")       ; stdlib: numeric/control macros (1+, ecase, rotatef...)
   (:file "macros-stdlib-ansi")  ; ANSI CL Phase 1 (psetf, assert, define-condition...)
   (:file "macros-stdlib-utils") ; list/tree/string/array utility macros
   (:file "macros-cxr")          ; algorithmic CXR accessor registration
   (:file "macros-hof")          ; higher-order list/search helpers (map/find/remove)
   (:file "macros-hof-search")   ; position/count/assoc search HOFs
   (:file "macros-filesystem")   ; file/IO/runtime helpers split from stdlib
   (:file "macros-sequence")     ; sequences: copy/fill/replace/mismatch/delete/substitute
   (:file "macros-sequence-fold") ; sequences: reduce/nsubstitute/map-into/merge/last/search
   (:file "macros-sequence-helpers")  ; list/sequence helper macros split from stdlib
   (:file "macros-plist")        ; property list helpers
   (:file "macros-package-system") ; package system and symbol-iteration macros
   (:file "macros-runtime-support") ; declarations, IO/hash/coerce/LTV/feature runtime macros
   (:file "macros-clos-protocol")  ; CLOS protocol: print-unreadable-object, describe, change-class
   (:file "macros-mop-support")   ; MOP introspection macros + parse-float + reinitialize-instance
   (:file "expander-data")       ; expander: grammar tables + dispatch table declarations
   (:file "runtime-stdlib-3-expander") ; runtime-stdlib-3 expander-side proclamations
   (:file "deftransform")        ; deftransform: type-specialized compile-time transforms
   (:file "expander-helpers")    ; expander: shared helper functions extracted from expander.lisp
   (:file "expander-defstruct-copy") ; expander: COPY-STRUCTURE expansion
   (:file "expander-defstruct-boa")  ; expander: BOA constructors for defstruct
   (:file "expander-defstruct-typed") ; expander: :TYPE list/vector defstruct forms
   (:file "expander-defstruct-clos")  ; expander: CLOS-backed defstruct forms
   (:file "expander-defstruct")       ; expander: defstruct dispatcher
   (:file "expander-typed-params") ; typed lambda-list helpers + *function-type-registry*
   (:file "expander-core")
   (:file "expander-definitions-helpers") ; expander: lambda-list default expansion helper
   (:file "expander-control-helpers") ; expander: binding helpers for control forms
   (:file "expander-setf-places-helpers") ; expander: setf-place cons access helper
   (:file "expander-setf-places") ; expander: setf compound-place registration table
   (:file "expander")
   (:file "expander-definitions-forms")
   (:file "expander-basic")      ; core application handlers split from expander.lisp
   (:file "expander-definitions")
   (:file "expander-control")
   (:file "expander-tail")
   (:file "expander-numeric")
   (:file "expander-sequence")
   (:file "macros-lazy")          ; FR-856 delay/force, FR-857 memoize
   ;; ── Phase 131: Pattern Matching Optimization ──
   (:file "pattern-opt-131")))

(defsystem "cl-cc-expand/test"
  :description "Test system for cl-cc-expand, running under cl-weave."
  :author "takeokunn <bararararatty@gmail.com>"
  :maintainer "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :version "0.1.0"
  :homepage "https://github.com/nerima-lisp/cl-cc-expand"
  :bug-tracker "https://github.com/nerima-lisp/cl-cc-expand/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-cc-expand.git")
  :depends-on ("cl-cc-expand" "cl-weave")
  :pathname "t"
  :serial t
  :components
  ((:file "package")
   (:file "macro-test")
   (:file "macro-definition-test")
   (:file "macro-assignment-test")
   (:file "macro-multiple-value-test")
   (:file "macros-control-flow-test")
   (:file "macros-control-flow-loop-test")
   (:file "macro-lambda-list-test")
   (:file "expander-lambda-list-defaults-test")
   (:file "expander-core-test")
   (:file "expander-data-test")
   (:file "expander-test-support")
   (:file "expander-basic-test")
   (:file "macros-basic-check-type-test")
   (:file "macros-basic-list-test")
   (:file "macros-basic-setf-test")
   (:file "expander-setf-test")
   (:file "expander-setf-places-test")
   (:file "expander-control-test")
   (:file "expander-array-test")
   (:file "expander-typed-test")
   (:file "expander-typed-params-test")
   (:file "expander-defclass-test")
   (:file "expander-binding-test")
   (:file "expander-control-helpers-test")
   (:file "expander-definitions-function-test")
   (:file "expander-definitions-forms-test")
   (:file "expander-definitions-type-test")
   (:file "expander-definitions-rounding-test")
   (:file "expander-definitions-constant-test")
   (:file "expander-definitions-test")
   (:file "expander-numeric-test")
   (:file "expander-comparison-test")
   (:file "expander-definitions-helpers-test")
   (:file "expander-helpers-test")
   (:file "expander-sequence-test")
   (:file "expander-setf-places-helpers-test")
   (:file "expander-tail-test")
   (:file "defstruct-test")
   (:file "expander-defstruct-typed-test")
   (:file "loop-test")
   (:file "loop-data-test")
   (:file "loop-parser-test")
   (:file "loop-emitters-test")
   (:file "macro-rotatef-test")
   (:file "macro-psetf-test")
   (:file "macro-shiftf-test")
   (:file "macro-ecase-test")
   (:file "macro-etypecase-test")
   (:file "macro-progv-test")
   (:file "macro-define-modify-macro-test")
   (:file "macros-cxr-test")
   (:file "macros-introspection-test")
   (:file "macros-list-utils-test")
   (:file "macros-restarts-test")
   (:file "macros-stdlib-core-test")
   (:file "macros-stdlib-test")
   (:file "macros-stdlib-bind-error-test")
   (:file "macros-stdlib-sequence-map-test")
   (:file "macros-stdlib-io-test")
   (:file "macros-stdlib-ansi-test")
   (:file "macros-stdlib-utils-test")
   (:file "macros-filesystem-test")
   (:file "array-predicate-expansion-test")
   (:file "macros-runtime-support-test")
   (:file "macros-clos-protocol-test")
   (:file "macros-plist-test")
   (:file "macros-sequence-helpers-test")
   (:file "macros-hof-test")
   (:file "macros-hof-search-test")
   (:file "macros-sequence-test")
   (:file "loop-macro-runtime-clauses-test")
   (:file "loop-macro-runtime-ext-test")
   (:file "syntax-rules-test")
   (:file "runtime-stdlib-2-expand-test")
   (:file "runtime-stdlib-3-expander-test")
   (:file "runtime-stdlib-3-sequence-test"))
  :perform (test-op (op system)
             (declare (ignore op system))
             (uiop:symbol-call :cl-weave :run-all
                               :reporter :spec
                               :pass-with-no-tests nil)))

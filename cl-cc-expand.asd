;;;; cl-cc-expand.asd — macro expansion subsystem for the cl-cc compiler.
;;;;
;;;; The nine public names used by cl-cc runtime integration are
;;;; RT-USE-PACKAGE, ADD-PACKAGE-LOCAL-NICKNAME,
;;;; %RECORD-DECLAIM-INLINE-CLAUSE, %RECORD-DECLAIM-OPTIMIZE-CLAUSE,
;;;; %RECORD-DECLAIM-TYPE-CLAUSE, %RECORD-DECLAIM-FTYPE-CLAUSE,
;;;; %RECORD-DECLAIM-SPECIAL-CLAUSE, *MACROEXPAND-STEP-CACHE*, and
;;;; *MACROEXPAND-ALL-CACHE*.
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
  :version "0.1.1"
  :homepage "https://github.com/nerima-lisp/cl-cc-expand"
  :bug-tracker "https://github.com/nerima-lisp/cl-cc-expand/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-cc-expand.git")
  :depends-on ("cl-cc-bootstrap" "cl-cc-type" "cl-cc-vm" "cl-host-kit")
  :in-order-to ((test-op (test-op "cl-cc-expand/test")))
  :pathname "src"
  :serial t
  :components
  ((:file "binding/package")
   (:file "expander/package")
   (:file "control/package")
   (:file "conditions/package")
   (:file "iteration/package")
   (:file "structures/package")
   (:file "places/package")
   (:file "clos/package")
   (:file "sequences/package")
   (:file "io/package")
   (:file "lists-and-sets/package")
   (:file "package")
   (:module "binding"
    :serial t
    :components
    ((:file "macro-lambda-list")
     (:file "registration")
     (:file "control-support")
     (:file "control")
     (:file "definitions-support")
     (:file "typed-params")))
   (:module "expander-kernel"
    :pathname "expander"
    :serial t
    :components
    ((:file "macro")
     (:file "macro-expansion")
     (:file "syntax-rules")
     (:file "data")
     (:file "deftransform")
     (:file "expansion-support")
     (:file "core")
     (:file "handler-registry")
     (:file "expander")
     (:file "binding-integration")
     (:file "runtime-support")
     (:file "runtime-stdlib-3-expander")))
   (:module "structures-core"
    :pathname "structures"
    :serial t
    :components
    ((:file "clos-hook")
     (:file "defstruct-boa")
     (:file "defstruct-copy")
     (:file "defstruct-typed")))
   (:module "clos"
    :serial t
    :components
    ((:file "defstruct-clos")
     (:file "register-struct-expansion")
     (:file "clos-protocol")
     (:file "mop-support")))
   (:module "structures-dispatcher"
    :pathname "structures"
    :serial t
    :components ((:file "defstruct")))
   (:module "control"
    :serial t
    :components ((:file "control-flow") (:file "control-flow-case")))
   (:module "conditions"
    :serial t
    :components ((:file "restarts")))
   (:module "iteration"
    :serial t
    :components
    ((:file "loop-data")
     (:file "loop-parser-for")
     (:file "loop-parser")
     (:file "loop-emitters")
     (:file "loop-iter-emitters")
     (:file "loop")
     (:file "iterator")
     (:file "package-system")))
   (:module "places"
    :serial t
    :components
    ((:file "basic")
     (:file "mutation")
     (:file "setf-place-support")
     (:file "setf-places")))
   (:module "sequences"
    :serial t
    :components
    ((:file "sequence")
     (:file "sequence-fold")
     (:file "sequence-support")
     (:file "hof")
     (:file "hof-search")))
   (:module "io"
    :serial t
    :components ((:file "filesystem")))
   (:module "lists-and-sets"
    :serial t
    :components
    ((:file "cxr")
     (:file "setops")
     (:file "list-operations")
     (:file "plist")
     (:file "introspection")))
   (:module "expander-stdlib"
    :pathname "expander"
    :serial t
    :components
    ((:file "basic")
     (:file "definitions-forms")
     (:file "definitions")
     (:file "numeric")
     (:file "tail")
     (:file "sequence")
     (:file "stdlib")
     (:file "stdlib-ansi")
     (:file "stdlib-common")
     (:file "lazy")
     (:file "pattern-opt-131")))))

(defsystem "cl-cc-expand/test"
  :description "Test system for cl-cc-expand, running under cl-weave."
  :author "takeokunn <bararararatty@gmail.com>"
  :maintainer "takeokunn <bararararatty@gmail.com>"
  :license "MIT"
  :version "0.1.1"
  :homepage "https://github.com/nerima-lisp/cl-cc-expand"
  :bug-tracker "https://github.com/nerima-lisp/cl-cc-expand/issues"
  :source-control (:git "https://github.com/nerima-lisp/cl-cc-expand.git")
  :depends-on ("cl-cc-expand" "cl-weave")
  :pathname "t"
  :serial t
  :components
  ((:file "package")
   (:file "expander-test-support")
   (:module "binding"
    :serial t
    :components
    ((:file "package") (:file "basic-mvb-test") (:file "binding-test")
     (:file "control-support-test") (:file "definitions-support-test")
     (:file "lambda-list-defaults-test") (:file "macro-lambda-list-test")
     (:file "macro-multiple-value-test") (:file "stdlib-bind-error-test") (:file "typed-params-test")))
   (:module "expander"
    :serial t
    :components
    ((:file "package") (:file "array-predicate-expansion-test")
     (:file "array-test") (:file "basic-test") (:file "comparison-test")
     (:file "core-test") (:file "data-test") (:file "definitions-constant-test")
     (:file "definitions-forms-test")
     (:file "typed-forms-test") (:file "definitions-function-test")
     (:file "definitions-rounding-test") (:file "definitions-test")
     (:file "definitions-type-test") (:file "expansion-support-test")
     (:file "macro-definition-test") (:file "macro-test") (:file "progv-macro-test") (:file "numeric-test")
     (:file "runtime-stdlib-2-expand-test")
     (:file "runtime-stdlib-3-expander-test") (:file "export-surface-test") (:file "runtime-support-test")
     (:file "sequence-test") (:file "stdlib-ansi-test")
     (:file "stdlib-core-test") (:file "stdlib-test")
     (:file "syntax-rules-test") (:file "tail-test")))
   (:module "control"
    :serial t
    :components
    ((:file "package") (:file "control-flow-loop-test")
     (:file "control-flow-test") (:file "control-test")
     (:file "macro-ecase-test") (:file "macro-etypecase-test")))
   (:module "conditions"
    :serial t
    :components
    ((:file "package") (:file "basic-check-type-test")
     (:file "restarts-test")))
   (:module "iteration"
    :serial t
    :components
    ((:file "package") (:file "loop-data-test")
     (:file "loop-emitters-test") (:file "loop-macro-expansion-test")
     (:file "loop-macro-expansion-clauses-test")
     (:file "loop-macro-expansion-errors-test") (:file "loop-parser-test")
     (:file "loop-test")))
   (:module "structures"
    :serial t
    :components
    ((:file "package") (:file "defstruct-test")
     (:file "defstruct-typed-test")))
   (:module "places"
    :serial t
    :components
    ((:file "package") (:file "basic-setf-test")
     (:file "macro-assignment-test") (:file "macro-define-modify-macro-test")
     (:file "macro-psetf-test") (:file "macro-rotatef-test")
     (:file "macro-shiftf-test") (:file "mutation-test")
     (:file "setf-place-support-test") (:file "setf-places-test")
     (:file "setf-test")))
   (:module "clos"
    :serial t
    :components
    ((:file "package") (:file "clos-protocol-test")
     (:file "defclass-test")))
   (:module "sequences"
    :serial t
    :components
    ((:file "package") (:file "hof-search-test") (:file "hof-test")
     (:file "runtime-stdlib-3-sequence-test")
     (:file "sequence-support-test") (:file "sequence-test")
     (:file "stdlib-sequence-map-test")))
   (:module "io"
    :serial t
    :components
    ((:file "package") (:file "filesystem-test") (:file "stdlib-io-test")))
   (:module "lists-and-sets"
    :serial t
    :components
    ((:file "package") (:file "basic-list-test") (:file "cxr-test")
     (:file "introspection-test") (:file "list-operations-test")
     (:file "plist-test") (:file "setops-test")
     (:file "stdlib-list-set-test") (:file "stdlib-common-test"))))
  :perform (test-op
    (op system)
    (declare (ignore op system))
    (unless (uiop:symbol-call :cl-weave :run-all :reporter :spec :pass-with-no-tests nil)
      (error "cl-cc-expand/test reported failing tests."))))

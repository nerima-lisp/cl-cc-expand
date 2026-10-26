;;;; packages/expand/src/package.lisp --- cl-cc/expand package definition
;;;;
;;;; Macro expansion subsystem: macro environment, defmacro machinery,
;;;; macroexpansion (our-macroexpand-1/-all), lambda-list parsing and
;;;; destructuring, and the LOOP/DO/CASE/TYPECASE control-flow macros.
;;;;
;;;; Uses cl-cc/bootstrap so source files can reference our-eval unqualified.
;;;; cl-cc/type is accessed qualified (cl-cc/type:...) so not in :use.

(defpackage :cl-cc/expand
  (:use :cl :cl-cc/bootstrap)
  (:shadow #:compiler-macro-function #:diagnostic)
  (:import-from :cl-cc/expand/expander
   #:*constant-table* #:*accessor-slot-map* #:*defstruct-read-only-accessor-map*
   #:*defstruct-slot-registry* #:*defstruct-type-registry* #:*defstruct-predicate-registry*
   #:*setf-compound-place-handlers* #:*declaim-inline-registry*
   #:*declaim-optimize-registry* #:*global-proclamations*
   #:with-fresh-defstruct-registries #:declaration-optimize-quality
   #:make-macro-expander #:macro-env #:macro-env-table #:our-defmacro
   #:our-macroexpand-1 #:our-macroexpand #:our-macroexpand-all #:register-macro
   #:lookup-macro #:*macro-environment* #:*macro-eval-fn* #:*symbol-macro-table*
   #:*compiler-macro-table* #:*deftransform-table* #:register-deftransform
   #:lookup-deftransform #:deftransform #:define-deftransform
   #:*macroexpand-step-cache* #:*macroexpand-all-cache* #:compiler-macroexpand-all
   #:defun/c #:copy-hash-table #:define-syntax #:syntax-rules #:with-gensyms
   #:once-only
   #:syntax-rules-expander #:expand-syntax-rules #:*syntax-rules-registry*
   #:syntax-case #:match-pattern #:build-template
   #:compile-pattern-decision-tree #:check-pattern-usefulness #:pattern-subsumes-p
   #:*trmc-enabled* #:trmc-optimize-form #:*join-points-enabled* #:introduce-join-points
   #:promise #:promisep #:%make-promise #:force #:delay #:memoize
   #:memoize-stats #:memoize-clear #:*memoize-registry*
   #:*compiler-special-forms-table* #:*all-builtin-names-table*
   #:*binary-builtins-table* #:*unary-builtins-table*
   #:*variadic-fold-builtins-table* #:*variadic-fold-or-list-table*
   #:likely #:unlikely #:%record-declaim-inline-clause
   #:%record-declaim-optimize-clause #:%record-declaim-type-clause
   #:%record-declaim-ftype-clause #:%record-declaim-special-clause)
  (:import-from :cl-cc/expand/binding
   #:parse-lambda-list #:destructure-lambda-list #:generate-lambda-bindings
   #:*function-type-registry* #:register-function-type #:lambda-list-has-typed-p
   #:strip-typed-params #:lambda-list-info-environment)
  (:import-from :cl-cc/expand/control
   #:dolist #:dotimes #:do #:do* #:case #:typecase)
  (:import-from :cl-cc/expand/iteration
   #:loop #:make-iterator #:iterator-next #:doiterator #:with-iterator
   #:rt-use-package #:add-package-local-nickname)
  (:import-from :cl-cc/expand/structures #:copy-structure)
  (:export
   #:*constant-table* #:*accessor-slot-map* #:*defstruct-read-only-accessor-map*
   #:*defstruct-slot-registry* #:*defstruct-type-registry* #:*defstruct-predicate-registry*
   #:*setf-compound-place-handlers* #:*declaim-inline-registry*
   #:*declaim-optimize-registry* #:*global-proclamations*
   #:with-fresh-defstruct-registries #:declaration-optimize-quality
   #:make-macro-expander #:macro-env #:macro-env-table #:our-defmacro
   #:our-macroexpand-1 #:our-macroexpand #:our-macroexpand-all #:register-macro
   #:lookup-macro #:*macro-environment* #:*macro-eval-fn* #:*symbol-macro-table*
   #:*compiler-macro-table* #:*deftransform-table* #:register-deftransform
   #:lookup-deftransform #:deftransform #:define-deftransform
   #:*macroexpand-step-cache* #:*macroexpand-all-cache*
   #:parse-lambda-list #:destructure-lambda-list #:generate-lambda-bindings
   #:compiler-macroexpand-all #:dolist #:dotimes #:do #:do* #:case #:typecase
   #:loop #:likely #:unlikely #:*function-type-registry* #:register-function-type
   #:lambda-list-has-typed-p #:strip-typed-params #:lambda-list-info-environment
   #:defun/c #:copy-hash-table #:copy-structure #:make-iterator #:iterator-next
   #:doiterator #:with-iterator #:define-syntax #:syntax-rules #:with-gensyms
   #:once-only
   #:syntax-rules-expander #:expand-syntax-rules #:*syntax-rules-registry*
   #:syntax-case #:match-pattern #:build-template
   #:compile-pattern-decision-tree #:check-pattern-usefulness #:pattern-subsumes-p
   #:*trmc-enabled* #:trmc-optimize-form #:*join-points-enabled* #:introduce-join-points
   #:promise #:promisep #:%make-promise #:force #:delay #:memoize
   #:memoize-stats #:memoize-clear #:*memoize-registry*
   #:*compiler-special-forms-table* #:*all-builtin-names-table*
   #:*binary-builtins-table* #:*unary-builtins-table*
   #:*variadic-fold-builtins-table* #:*variadic-fold-or-list-table*
   #:rt-use-package #:add-package-local-nickname
   #:%record-declaim-inline-clause #:%record-declaim-optimize-clause
   #:%record-declaim-type-clause #:%record-declaim-ftype-clause
   #:%record-declaim-special-clause))

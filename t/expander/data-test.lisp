;;;; tests/unit/expand/expander-data-tests.lisp — Expander data table tests

(in-package :cl-cc/expand/expander/test)

(defsuite expander-data-suite :description "Expander data table unit tests"
  :parent cl-cc-unit-suite)


(in-suite expander-data-suite)
(deftest-each builtin-table-members
  "Key symbols are present in their respective builtin tables."
  :cases (("variadic-+"      '+      cl-cc/expand/expander:*variadic-fold-builtins*)
          ("variadic-*"      '*      cl-cc/expand/expander:*variadic-fold-builtins*)
          ("variadic-append" 'append cl-cc/expand/expander:*variadic-fold-builtins*)
          ("variadic-nconc"  'nconc  cl-cc/expand/expander:*variadic-fold-builtins*)
          ("binary-cons"     'cons   cl-cc/expand/expander:*binary-builtins*)
          ("binary-="        '=      cl-cc/expand/expander:*binary-builtins*)
          ("binary-mod"      'mod    cl-cc/expand/expander:*binary-builtins*)
          ("binary-ash"      'ash    cl-cc/expand/expander:*binary-builtins*)
          ("binary-bit-ior"  'bit-ior cl-cc/expand/expander:*binary-builtins*)
          ("unary-car"       'car    cl-cc/expand/expander:*unary-builtins*)
          ("unary-cdr"       'cdr    cl-cc/expand/expander:*unary-builtins*)
          ("unary-not"       'not    cl-cc/expand/expander:*unary-builtins*)
          ("unary-length"    'length cl-cc/expand/expander:*unary-builtins*))
  (sym table)
  (assert-true (member sym table)))

(deftest cxr-builtins-completeness
  "*cxr-builtins* has all 28 compositions."
  (assert-equal 28 (length cl-cc/expand/expander:*cxr-builtins*))
  (assert-true (member 'caar cl-cc/expand/expander:*cxr-builtins*))
  (assert-true (member 'cddddr cl-cc/expand/expander:*cxr-builtins*)))

(deftest-each all-builtin-names-members
  "*all-builtin-names* is the union of all sub-tables and contains representative symbols."
  :cases (("variadic-+"   '+    cl-cc/expand/expander:*all-builtin-names*)
          ("binary-cons"  'cons cl-cc/expand/expander:*all-builtin-names*)
          ("unary-car"    'car  cl-cc/expand/expander:*all-builtin-names*)
          ("cxr-caar"     'caar cl-cc/expand/expander:*all-builtin-names*)
          ("special-list" 'list cl-cc/expand/expander:*all-builtin-names*))
  (sym table)
  (assert-true (member sym table)))

(deftest expander-data-registry-sanity
  "Core data registries and query helpers in expander-data.lisp are wired and readable."
  (assert-true (hash-table-p cl-cc/expand:*accessor-slot-map*))
  (assert-true (hash-table-p cl-cc/expand:*defstruct-slot-registry*))
  (assert-true (hash-table-p cl-cc/expand:*defstruct-type-registry*))
  (assert-true (hash-table-p cl-cc/expand:*symbol-macro-table*))
  (assert-true (hash-table-p cl-cc/expand:*constant-table*))
  (assert-true (hash-table-p cl-cc/expand:*compiler-macro-table*))
  (assert-true (hash-table-p cl-cc/expand/expander:*setf-compound-place-handlers*))
  (assert-true (functionp cl-cc/expand:*macro-eval-fn*))
  (assert-true (cl-cc/expand/expander:compiler-special-form-p 'if))
  (assert-false (cl-cc/expand/expander:compiler-special-form-p 'not-a-special-form))
  (assert-true (cl-cc/expand/expander:builtin-name-p 'append))
  (assert-true (cl-cc/expand/expander:builtin-name-p 'bit-ior))
  (assert-false (cl-cc/expand/expander:builtin-name-p 'bit-or))
  (assert-false (cl-cc/expand/expander:builtin-name-p 'not-a-builtin))
   (assert-equal 0 (cl-cc/expand/expander:variadic-fold-identity '+))
   (assert-equal 1 (cl-cc/expand/expander:variadic-fold-identity '*))
   (assert-equal nil (cl-cc/expand/expander:variadic-fold-identity 'length)))

(deftest bootstrap-macro-eval-errors-without-our-eval
  "%bootstrap-macro-eval rejects host fallback when OUR-EVAL is unavailable."
  (let ((original (when (fboundp 'cl-cc/bootstrap:our-eval)
                    (symbol-function 'cl-cc/bootstrap:our-eval))))
    (unwind-protect
         (progn
           (when original
             (fmakunbound 'cl-cc/bootstrap:our-eval))
           (assert-signals error
             (cl-cc/expand/expander:%bootstrap-macro-eval '(+ 1 2))))
      (when original
        (setf (symbol-function 'cl-cc/bootstrap:our-eval) original)))))

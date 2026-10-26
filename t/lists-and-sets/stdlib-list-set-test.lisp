;;;; tests/unit/expand/macros-stdlib-list-set-tests.lisp
;;;; Coverage tests for src/expand/macros-stdlib.lisp

(in-package :cl-cc/expand/lists-and-sets/test)

(defsuite macros-stdlib-list-set-suite
  :description "Tests for macros-stdlib.lisp: list/set/sequence basics"
  :parent cl-cc-integration-suite)

(in-suite macros-stdlib-list-set-suite)

(deftest concatenate-list-expands-to-append
  "CONCATENATE 'list expands to APPEND over each argument coerced to a list, so a
vector or string argument concatenates instead of being spliced in as an atom."
  (assert-equal (our-macroexpand-1 '(concatenate 'list '(1 2) '(3 4)))
                '(append (coerce '(1 2) 'list) (coerce '(3 4) 'list))))

(deftest-each concatenate-vector-types-expand-to-coerce-to-vector
  "CONCATENATE 'vector and 'simple-vector both use the coerce-to-vector path."
  :cases (("vector"        '(concatenate 'vector '(1) '(2)))
          ("simple-vector" '(concatenate 'simple-vector '(1) '(2))))
  (form)
  (let ((result (our-macroexpand-1 form)))
    (assert-equal (symbol-name (car result)) "COERCE-TO-VECTOR")
    (assert-eq (caadr result) 'append)))

(deftest nreconc-expands-to-nconc-nreverse
  "NRECONC expands to (nconc (nreverse list) tail)."
  (let ((result (our-macroexpand-1 '(nreconc lst tail))))
    (assert-eq (car result) 'nconc)
    (assert-eq (caadr result) 'nreverse)
    (assert-eq (caddr result) 'tail)))

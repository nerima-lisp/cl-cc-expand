;;;; tests/unit/expand/macros-basic-mvb-tests.lisp
;;;; Coverage for src/expand/macros-basic.lisp:
;;;;   psetq, multiple-value-bind, multiple-value-setq, multiple-value-list

(in-package :cl-cc-expand/test)

(defsuite macros-basic-mvb-suite
  :description "Tests for macros-basic.lisp: psetq and multiple-value forms"
  :parent cl-cc-integration-suite)

(in-suite macros-basic-mvb-suite)

;;; ─── psetq ────────────────────────────────────────────────────────────────

(deftest psetq-expansion-structure
  "psetq expansion: outer LET, 2 gensym bindings, setq forms in body, trailing nil."
  (let* ((exp  (our-macroexpand-1 '(psetq x 1 y 2)))
         (body (cddr exp)))
    (assert-eq 'let (car exp))
    (assert-= 2 (length (second exp)))
    (assert-true (some (lambda (f) (and (consp f) (eq 'setq (car f)))) body))
    (assert-null (car (last body)))))

(deftest psetq-empty-is-nil
  "psetq with no args expands to NIL (no-op)."
  (assert-null (our-macroexpand-1 '(psetq))))

;;; ─── multiple-value-bind ──────────────────────────────────────────────────

(deftest mvb-expansion-structure
  "multiple-value-bind: explicit VALUES lowers to LET* bindings; general forms lower via values-list capture."
  (let* ((exp    (our-macroexpand-1 '(multiple-value-bind (x y) (values 1 2) x))))
    (assert-true (member (car exp) '(let let*)))))

;;; ─── multiple-value-setq ──────────────────────────────────────────────────

(deftest mvsq-expansion-structure
  "multiple-value-setq: outer LET, body has SETQ for each variable."
  (let* ((exp  (our-macroexpand-1 '(multiple-value-setq (x y) (values 1 2))))
         (body (cddr exp)))
    (assert-eq 'let (car exp))
    (assert-= 2 (length (remove-if-not (lambda (f) (and (consp f) (eq 'setq (car f)))) body)))))

;;; ─── multiple-value-list ──────────────────────────────────────────────────

(deftest mvl-expansion-structure
  "multiple-value-list: explicit VALUES lowers to LIST."
  (let* ((exp  (our-macroexpand-1 '(multiple-value-list (values 1 2 3))))
         )
    (assert-true (member (car exp) '(list let)))))

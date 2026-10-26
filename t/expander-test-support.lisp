;;;; tests/unit/expand/expander-test-support.lisp — Shared expansion test helpers

(in-package :cl-cc-expand/test)

(defmacro assert-expansion-head (form expected-head)
  `(let ((result (cl-cc/expand:compiler-macroexpand-all ,form)))
     (assert-eq ,expected-head (car result))
     result))

(defmacro assert-no-expansion (form)
  `(assert-equal ,form (our-macroexpand-1 ,form)))

(defmacro assert-form-string-contains (form expected-substring)
  `(assert-true (search ,expected-substring (format nil "~S" ,form))))

(defmacro assert-expanded-string-contains (form expected-substring)
  `(assert-form-string-contains (cl-cc/expand:compiler-macroexpand-all ,form)
     ,expected-substring))

(defmacro assert-form-string-not-contains (form unexpected-substring)
  `(assert-false (search ,unexpected-substring (format nil "~S" ,form))))

(defmacro assert-expanded-string-not-contains (form unexpected-substring)
  `(assert-form-string-not-contains
       (cl-cc/expand:compiler-macroexpand-all ,form)
       ,unexpected-substring))

(defun %tree-contains-head-p (head form)
  "True if FORM contains any cons whose CAR is HEAD."
  (cond ((consp form)
         (or (eq (car form) head)
             (%tree-contains-head-p head (car form))
             (%tree-contains-head-p head (cdr form))))
        (t nil)))

(defun %find-call-in-form (head form)
  "Return the first (HEAD ...) subform of FORM, searching depth-first.

The searches below have to recurse: ASSERT's failure branch is now
(let ((c ...)) (signal c) (cerror \"Continue.\" c)), so the CERROR call sits a
level down and its datum is the LET variable rather than the literal. The SIGNAL
runs HANDLER-BIND's handlers on the guest stack, where an INVOKE-RESTART from one
of them can throw to this ASSERT's own RESTART-CASE."
  (cond
    ((not (consp form)) nil)
    ((eq (car form) head) form)
    (t (some (lambda (sub) (%find-call-in-form head sub)) form))))

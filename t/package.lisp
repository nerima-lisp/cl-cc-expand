;;;; t/package.lisp — cl-cc-expand test package + cl-weave compatibility shim.
;;;;
;;;; The cl-cc-expand suite was written against the monorepo's deftest /
;;;; deftest-each / assert-* macros (packages/testing-framework). Rather
;;;; than rewrite ~90 files by hand, this shim re-expresses those forms on
;;;; top of cl-weave's it-sequential / expect, so every test runs on
;;;; cl-weave unchanged apart from its in-package form. This is the same
;;;; shim shape cl-cc-type used for its own (much larger) monorepo-deftest
;;;; suite; see that repository's t/package.lisp for the precedent.
;;;;
;;;; Note on ASSERT-SIGNALS: the monorepo's own framework version
;;;; (packages/testing-framework/src/framework-assertions.lisp) already
;;;; fails correctly when no condition is signaled or the wrong condition
;;;; type is signaled — this shim preserves that (correct) behavior rather
;;;; than the older always-passes bug documented for some earlier
;;;; extractions.

(defpackage :cl-cc-expand/test
  (:use :cl :cl-weave)
  (:shadowing-import-from :cl-weave #:describe)
  ;; The monorepo's shared cl-cc/test package explicitly IMPORTs (not USEs)
  ;; exactly these three cl-cc/expand symbols unqualified
  ;; (packages/testing-framework/src/package-imports-backend.lisp) — a
  ;; blanket :USE of :cl-cc/expand is not safe here: that package's export
  ;; list itself shadows/re-exports CL-name-colliding symbols (LOOP, DO,
  ;; DO*, CASE, TYPECASE, DOLIST, DOTIMES, COMPILER-MACRO-FUNCTION,
  ;; DIAGNOSTIC) that would conflict with :CL. Everything else in the test
  ;; bodies below reaches cl-cc/expand qualified
  ;; (cl-cc/expand:compiler-macroexpand-all, cl-cc/expand::%loop-... for
  ;; white-box internals, etc.), matching the monorepo originals verbatim.
  (:import-from :cl-cc/expand
   #:our-macroexpand-1 #:our-macroexpand #:our-macroexpand-all)
  (:export #:deftest #:deftest-each #:in-suite #:defsuite #:defbefore
           #:assert-true #:assert-false #:assert-eq #:assert-eql
           #:assert-= #:assert-equal #:assert-equalp #:assert-null
           #:assert-string= #:assert-signals))

(in-package :cl-cc-expand/test)

;;; ── test definition shims ────────────────────────────────────────────────

(defun %test-name (designator)
  (if (stringp designator) designator (string-downcase (string designator))))

(defmacro deftest (name &body body)
  "Monorepo deftest -> a single cl-weave sequential test. A leading string
body form is treated as the (dropped) docstring."
  (when (and (stringp (first body)) (rest body))
    (setf body (rest body)))
  `(it-sequential ,(%test-name name) ,@body))

(defmacro deftest-each (base-name &body args)
  "Monorepo deftest-each -> one cl-weave test per case.
Syntax: (deftest-each name [docstring] :cases ((label val ...) ...) (var ...) body...)."
  (when (stringp (first args))
    (setf args (rest args)))
  (let* ((cases-pos (position :cases args))
         (cases (nth (1+ cases-pos) args))
         (tail  (nthcdr (+ 2 cases-pos) args))
         (vars  (first tail))
         (body  (rest tail)))
    `(progn
       ,@(loop for case in cases
               for label = (first case)
               for vals  = (rest case)
               collect `(it-sequential ,(format nil "~A ~A" (%test-name base-name) label)
                          (destructuring-bind ,vars (list ,@vals)
                            (declare (ignorable ,@vars))
                            ,@body))))))

(defmacro in-suite (&rest ignored)
  "Suites are a monorepo concept; cl-weave groups by describe. No-op here."
  (declare (ignore ignored))
  nil)

(defmacro defsuite (name &rest options)
  "Monorepo suite declaration; no-op on cl-weave (tests run flat)."
  (declare (ignore name options))
  nil)

(defmacro defbefore (kind suites &body body)
  "Monorepo suite-scoped setup hook -> cl-weave root before-each/before-all.
The suite argument is ignored; the hook applies to the flat test set."
  (declare (ignore suites))
  (ecase kind
    (:each `(before-each ,@body))
    (:all  `(before-all ,@body))))

;;; ── assertion shims (map onto cl-weave expect) ───────────────────────────

(defmacro assert-true (form &rest _)       (declare (ignore _)) `(expect ,form :to-be-truthy))
(defmacro assert-false (form &rest _)      (declare (ignore _)) `(expect ,form :to-be-falsy))
(defmacro assert-null (form &rest _)       (declare (ignore _)) `(expect ,form :to-be-null))
(defmacro assert-eq (expected actual &rest _)     (declare (ignore _)) `(expect ,actual :to-be ,expected))
(defmacro assert-eql (expected actual &rest _)    (declare (ignore _)) `(expect ,actual :to-be ,expected))
(defmacro assert-= (expected actual &rest _)      (declare (ignore _)) `(expect ,actual :to-equal ,expected))
(defmacro assert-equal (expected actual &rest _)  (declare (ignore _)) `(expect ,actual :to-equal ,expected))
(defmacro assert-equalp (expected actual &rest _) (declare (ignore _)) `(expect ,actual :to-equalp ,expected))
(defmacro assert-string= (expected actual &rest _) (declare (ignore _)) `(expect ,actual :to-equal ,expected))

(defmacro assert-signals (condition-type form)
  "Assert that form signals a condition of condition-type. Matches the
monorepo framework's own (already-correct) semantics: fails if nothing is
signaled, and fails if the wrong condition type is signaled."
  `(handler-case
       (progn
         ,form
         (fail "assert-signals: expected ~S to be signaled, but no condition was raised"
               ',condition-type))
     (,condition-type () t)
     (error (c)
       (fail "assert-signals: expected ~S but got ~S: ~A"
             ',condition-type (type-of c) c))))

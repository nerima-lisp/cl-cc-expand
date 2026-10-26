;;;; t/expander/predicate-expansion-shape-test.lisp — Predicate expansion shape tests

(in-package :cl-cc-expand/test)

;;; ─── Sequence-dispatch aware expansion accessors ────────────────────────
;;;
;;; The sequence predicates no longer expand straight into a list loop. When the
;;; sequence argument is not a literal, %SEQUENCE-DISPATCH-EXPAND (see
;;; src/sequences/hof.lisp) wraps the four per-type bodies in
;;;
;;;   (let ((#:seq <sequence>)) (typecase #:seq (list ...) (string ...)
;;;                                             (vector ...) (otherwise ...)))
;;;
;;; so that these functions accept strings and vectors as ANSI requires, not
;;; just lists. The tests below still care about the shape of the *list* body,
;;; so they reach it through these two helpers instead of asserting on a raw
;;; CADDR that now names the dispatch form.

(defun predicate-expansion-list-body (form)
  "Return the list-sequence body of FORM's one-step macro expansion.

Peels the %SEQUENCE-DISPATCH-EXPAND wrapper when it is present, and returns the
expansion unchanged when the sequence argument was a literal and the macro
therefore selected a path at expansion time. Returns the body itself, so callers
assert on the same form they used to get before the dispatch wrapper existed."
  (let ((expansion (our-macroexpand-1 form)))
    (if (and (consp expansion)
             (eq (car expansion) 'let)
             (consp (caddr expansion))
             (eq (car (caddr expansion)) 'typecase))
        (second (assoc 'list (cddr (caddr expansion))))
        expansion)))

(it-sequential "predicate-not-delegates-via-complement find-if-not"
  (destructuring-bind (base-op form) (list 'find-if '(find-if-not pred lst))
    (let ((result (our-macroexpand-1 form)))
    (expect (car result) :to-be base-op)
    (expect (caadr result) :to-be 'complement))))

(it-sequential "predicate-not-delegates-via-complement position-if-not"
  (destructuring-bind (base-op form) (list 'position-if '(position-if-not pred lst))
    (let ((result (our-macroexpand-1 form)))
    (expect (car result) :to-be base-op)
    (expect (caadr result) :to-be 'complement))))

(it-sequential "predicate-not-delegates-via-complement count-if-not"
  (destructuring-bind (base-op form) (list 'count-if '(count-if-not pred lst))
    (let ((result (our-macroexpand-1 form)))
    (expect (car result) :to-be base-op)
    (expect (caadr result) :to-be 'complement))))

(it-sequential "predicate-not-delegates-via-complement rassoc-if-not"
  (destructuring-bind (base-op form) (list 'rassoc-if '(rassoc-if-not pred alist))
    (let ((result (our-macroexpand-1 form)))
    (expect (car result) :to-be base-op)
    (expect (caadr result) :to-be 'complement))))

(it-sequential "predicate-not-delegates-via-complement assoc-if-not"
  (destructuring-bind (base-op form) (list 'assoc-if '(assoc-if-not pred alist))
    (let ((result (our-macroexpand-1 form)))
    (expect (car result) :to-be base-op)
    (expect (caadr result) :to-be 'complement))))

(it-sequential "position-if-expansion-structure"
  (let* ((list-body (predicate-expansion-list-body '(position-if pred lst)))
         (body      (caddr list-body)))
    (expect (car list-body) :to-be 'let)
    (expect (car body) :to-be 'block)
    (expect (second body) :to-be nil)))

(it-sequential "remove-if-key-expansion remove-if"
  (destructuring-bind (form) (list '(remove-if #'oddp lst :key #'car))
    (let ((list-body (predicate-expansion-list-body form)))
    (expect (car list-body) :to-be 'let)
    (expect (> (length (cadr list-body)) 1) :to-be-truthy))))

(it-sequential "remove-if-key-expansion remove-if-not"
  (destructuring-bind (form) (list '(remove-if-not #'evenp lst :key #'car))
    (let ((list-body (predicate-expansion-list-body form)))
    (expect (car list-body) :to-be 'let)
    (expect (> (length (cadr list-body)) 1) :to-be-truthy))))

(it-sequential "find-if-not-with-key"
  (let ((result (our-macroexpand-1 '(find-if-not #'oddp lst :key #'car))))
    (expect 'find-if :to-be (car result))))

(it-sequential "position-if-with-key"
  (let ((list-body (predicate-expansion-list-body '(position-if #'oddp lst :key #'car))))
    (expect 'let :to-be (car list-body))
    (expect (> (length (cadr list-body)) 2) :to-be-truthy)))

(it-sequential "count-if-not-with-key"
  (let ((result (our-macroexpand-1 '(count-if-not #'oddp lst :key #'car))))
    (expect 'count-if :to-be (car result))))

(it-sequential "predicate-if-outer-is-let rassoc-if"
  (destructuring-bind (form) (list '(rassoc-if pred alist))
    (expect (car (our-macroexpand-1 form)) :to-be 'let)))

(it-sequential "predicate-if-outer-is-let assoc-if"
  (destructuring-bind (form) (list '(assoc-if pred alist))
    (expect (car (our-macroexpand-1 form)) :to-be 'let)))

(it-sequential "rassoc-if-body-checks-cdr"
  (let* ((result (our-macroexpand-1 '(rassoc-if pred alist)))
         (dolist-form (caddr result))
         (when-form (second (cdr dolist-form)))
         (and-form (second when-form))
         (funcall-form (third and-form))
         (cdr-arg (caddr funcall-form)))
    (expect 'dolist :to-be (car dolist-form))
    (expect 'funcall :to-be (car funcall-form))
    (expect 'cdr :to-be (car cdr-arg))))


(it-sequential "assoc-if-body-is-dolist"
  (let* ((list-body (predicate-expansion-list-body '(assoc-if pred alist)))
         (body      (caddr list-body)))
    (expect 'dolist :to-be (car body))))


(it-sequential "complement-expansion-structure top-is-let"
  (destructuring-bind (expected accessor) (list 'let (lambda (r) (car r)))
    (expect (funcall accessor (our-macroexpand-1 '(complement pred))) :to-be expected)))

(it-sequential "complement-expansion-structure inner-lambda"
  (destructuring-bind (expected accessor) (list 'lambda (lambda (r) (car (caddr r))))
    (expect (funcall accessor (our-macroexpand-1 '(complement pred))) :to-be expected)))

(it-sequential "complement-expansion-structure body-if-head"
  (destructuring-bind (expected accessor) (list 'if (lambda (r) (car (caddr (caddr r)))))
    (expect (funcall accessor (our-macroexpand-1 '(complement pred))) :to-be expected)))

(it-sequential "complement-expansion-structure apply-in-if"
  (destructuring-bind (expected accessor) (list 'apply (lambda (r) (car (cadr (caddr (caddr r))))))
    (expect (funcall accessor (our-macroexpand-1 '(complement pred))) :to-be expected)))

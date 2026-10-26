(in-package :cl-cc/expand/expander)

;;; FR-607: Strip leading docstring from body (string + more forms → skip string)
;;; Returns (stripped-body . docstring-or-nil)
(defun %strip-docstring (body)
  (if (and (stringp (car body)) (cdr body))
      (cdr body)
      body))

(defun %extract-docstring (body)
  "Return the docstring if BODY starts with one (and has more forms), else nil."
  (if (and (stringp (car body)) (cdr body))
      (car body)
      nil))

(defun %build-setf-progn-forms (args)
  "Build one SETF form per place/value pair in ARGS."
  (loop for kv on args by #'cddr
        when (cdr kv)
          collect (list 'setf (car kv) (cadr kv))))

;; defsetf — register a setf expander for an accessor (FR-355)
;; Short form: (defsetf accessor updater) → (updater args... value)
;; Long form: (defsetf accessor lambda-list (store-var) body...)
;; define-setf-expander — register setf expansion function (FR-355)
;; (define-setf-expander accessor (lambda-list) body...)
;; defconstant — compile-time constants treated as defparameter
(define-expander-for defconstant (form)
  (let ((name (second form))
        (value (third form)))
    (setf (gethash name *constant-table*) value)
    (compiler-macroexpand-all (list 'defparameter name value))))

;; setf — unified place dispatcher
;; make-array — preserve keyword calls for backend lowering
(define-expander-for make-array (form)
  (if (>= (length form) 4)
      (expand-make-array-form (second form) (cddr form))
      (cons 'make-array (mapcar #'compiler-macroexpand-all (cdr form)))))

;; defstruct — expand to defclass + constructor + predicate
;; eval-when — phase control (compile-toplevel vs execute/load-toplevel)
(define-expander-for eval-when (form)
  (expand-eval-when-form (second form) (cddr form)))

;; macrolet — local macro bindings scoped to body
(define-expander-for macrolet (form)
  (expand-macrolet-form (second form) (cddr form)))

;; symbol-macrolet — local symbol macro bindings scoped to body (FR-398)
(define-expander-for symbol-macrolet (form)
  (expand-symbol-macrolet-form (second form) (cddr form)))

;; define-symbol-macro — global symbol macro definition (FR-398)
(define-expander-for define-symbol-macro (form)
  (let ((name (second form))
        (expansion (third form)))
    (setf (gethash name *symbol-macro-table*) expansion)
    (list 'quote name)))

;; vector — variadic vector constructor (vector a b c) → #(a b c)
(define-expander-for vector (form)
  (compiler-macroexpand-all
   (list 'coerce-to-vector (cons 'list (cdr form)))))

;; get-decoded-time — 0-arg form, expands to decode-universal-time call
(define-expander-for get-decoded-time (form)
  (declare (ignore form))
  '(decode-universal-time (get-universal-time)))

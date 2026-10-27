(in-package :cl-cc/expand/places)

;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;;; Expander — setf compound-place handlers
;;;
;;; Fact table for place-head symbols. Each entry is a simple registration.
;;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun %register-setf-place-handler (head handler)
    "Register HANDLER under HEAD in *SETF-COMPOUND-PLACE-HANDLERS*."
    (setf (gethash head *setf-compound-place-handlers*) handler)
    head)

  (defun %register-shared-setf-place-handler (heads handler)
    "Register HANDLER for each symbol in HEADS."
    (dolist (sym heads)
      (setf (gethash sym *setf-compound-place-handlers*) handler))
    heads))

(%register-setf-place-handler
 'aref
 (lambda (place value)
   (compiler-macroexpand-all
    (list 'aset (second place) (third place) value))))

(%register-setf-place-handler
 'getf
  (lambda (place value)
    (let ((plist-place (second place))
          (indicator (third place))
          (v (gensym "V")))
      (compiler-macroexpand-all
       (list 'let (list (list v value))
             (if (symbolp plist-place)
                 (list 'setq plist-place
                       (list 'rt-plist-put plist-place indicator v))
                 (list 'setf plist-place
                       (list 'rt-plist-put plist-place indicator v)))
             v)))))

(%register-setf-place-handler
 'fill-pointer
 (lambda (place value)
   (compiler-macroexpand-all
    (list '%set-fill-pointer (second place) value))))

(%register-setf-place-handler
 'get
 (lambda (place value)
   (let ((sym (gensym "SYM"))
         (ind (gensym "IND"))
         (v (gensym "V")))
     (compiler-macroexpand-all
      (list 'let* (list (list sym (second place))
                        (list ind (third place))
                        (list v value))
            (list '%set-symbol-plist sym
                  (list 'rt-plist-put (list 'symbol-plist sym) ind v))
            v)))))

;; All cons-cell accessors share the same expansion logic — hoist the closure once
(%register-shared-setf-place-handler
 '(car first cdr rest nth
   second third fourth fifth sixth seventh eighth ninth tenth
   caar cadr cdar cddr
   caaar cdaar cadar cddar caadr cdadr caddr cdddr
   caaaar cadaar caadar caddar cdaaar cddaar cdadar cdddar
   caaadr cadadr caaddr cadddr cdaadr cddadr cdaddr cddddr)
  (lambda (place value)
    (compiler-macroexpand-all (expand-setf-cons-place place value))))

;;; FR-593: (setf (subseq seq start end) new-seq) → (replace seq new-seq :start1 start :end1 end)
(%register-setf-place-handler
 'subseq
 (lambda (place value)
   (compiler-macroexpand-all
    (append (list 'replace (second place) value :start1 (third place))
            (when (fourth place)
              (list :end1 (fourth place)))))))

;;; FR-614: (setf (char s i) v) and (setf (schar s i) v)
(%register-shared-setf-place-handler
 '(char schar)
 (lambda (place value)
   (compiler-macroexpand-all
    (list 'rt-string-set (second place) (third place) value))))

;;; FR-636: (setf (bit bv i) x) and (setf (sbit bv i) x)
(%register-shared-setf-place-handler
 '(bit sbit)
 (lambda (place value)
   (compiler-macroexpand-all
    (list 'rt-bit-set (second place) (third place) value))))

;;; FR-620: (setf (svref v i) x) and (setf (row-major-aref a i) x)
(%register-setf-place-handler
 'svref
 (lambda (place value)
   (compiler-macroexpand-all
    (list '%svset (second place) (third place) value))))

(%register-setf-place-handler
 'row-major-aref
 (lambda (place value)
   (compiler-macroexpand-all
    (list 'aset (second place) (third place) value))))

;;; FR-552: (setf (find-class name) class) → register in class registry
(%register-setf-place-handler
 'find-class
 (lambda (place value)
   (compiler-macroexpand-all
    (list '%set-find-class (second place) value))))

;;; FR-548: (setf (symbol-function name) fn) → host bridge
(%register-setf-place-handler
 'symbol-function
 (lambda (place value)
   (compiler-macroexpand-all
    (list 'set-fdefinition value (second place)))))

;;; (setf (fdefinition name) fn) → host bridge, same lowering as symbol-function
(%register-setf-place-handler
 'fdefinition
 (lambda (place value)
   (compiler-macroexpand-all
    (list 'set-fdefinition value (second place)))))

;;; FR-586: (setf (symbol-value name) value) → host bridge
(%register-setf-place-handler
 'symbol-value
 (lambda (place value)
   (let ((sym (gensym "SYM"))
         (v (gensym "V"))
         (fn (gensym "SET-SYMBOL-VALUE-FN")))
     (compiler-macroexpand-all
      (list 'let (list (list sym (second place))
                       (list v value)
                       (list fn 'cl-cc/bootstrap:*runtime-set-symbol-value-fn*))
             (list 'funcall fn sym v)
             v)))))

;;; FR-592: (setf (readtable-case readtable) case) → stdlib compatibility setter
;;;
;;; Registered under every READTABLE-CASE symbol the reader can hand us, not
;;; just the one this file's package resolves. *SETF-COMPOUND-PLACE-HANDLERS*
;;; is an EQ table; compiled cl-cc source is read into :CL-CC, where
;;; READTABLE-CASE is CL-CC/VM:READTABLE-CASE, while the bare symbol here reads
;;; as CL:READTABLE-CASE. Registering only the latter made
;;; (setf (readtable-case rt) :downcase) miss the table and expand into a form
;;; that silently left the readtable alone.
(%register-shared-setf-place-handler
 (remove nil
         (remove-duplicates
          (list 'readtable-case
                (let ((vm-package (find-package "CL-CC/VM")))
                  (and vm-package (find-symbol "READTABLE-CASE" vm-package))))
          :test #'eq))
 (lambda (place value)
   (let ((readtable-var (gensym "READTABLE-CASE-PLACE-"))
         (case-var (gensym "READTABLE-CASE-VALUE-"))
         (target-var (gensym "READTABLE-CASE-TARGET-")))
     (compiler-macroexpand-all
      (list 'let*
            (list (list readtable-var (second place))
                  (list case-var value)
                  (list target-var
                        (list 'if readtable-var readtable-var
                              'cl-cc/vm/io:*readtable*)))
            (list 'unless
                  (list 'member case-var
                        (list 'quote '(:upcase :downcase :preserve :invert)))
                  (list 'error "Invalid readtable case"))
            (list 'setf (list 'gethash :case target-var) case-var)
            case-var)))))

;;; FR-428: (setf (macro-function name) fn) → host bridge
(%register-setf-place-handler
 'macro-function
 (lambda (place value)
   (compiler-macroexpand-all
    (list '%set-macro-function (second place) value))))

;;; FR-603: (setf (values a b ...) expr) → capture values list + setq chain
(%register-setf-place-handler
 'values
   (lambda (place value)
     (let* ((vars  (cdr place))
            (temp  (gensym "MVS"))
            (assignments (loop for x in vars
                               for i from 0
                               collect (list 'setq x (list 'nth i temp)))))
       (compiler-macroexpand-all
        (cons 'let
              (cons (list (list temp (list 'multiple-value-list value)))
                    (append assignments
                            (list (list 'car temp)))))))))

(in-package :cl-cc/expand/places)

(define-expander-for setf (form)
  (let ((len (length form)))
    (if (and (> len 3) (evenp (1- len)))
        ;; (setf a 1 b 2 ...) → (progn (setf a 1) (setf b 2) ...)
        (compiler-macroexpand-all
         (cons 'progn (%build-setf-progn-forms (cdr form))))
        (if (and (= len 3) (symbolp (second form)))
            ;; (setf var val) → (setq var val)
            (compiler-macroexpand-all (list 'setq (second form) (third form)))
            (if (and (= len 3) (consp (second form)))
                ;; compound place — table lookup first, then generic accessor, then passthrough
                (let* ((place   (second form))
                       (value   (third form))
                       (handler (gethash (car place) *setf-compound-place-handlers*)))
                  (if handler
                      (funcall handler place value)
                      (if (and (symbolp (car place)) (= (length place) 2))
                          (expand-setf-accessor place value)
                          (cons 'setf (mapcar #'compiler-macroexpand-all (cdr form))))))
                (cons 'setf (mapcar #'compiler-macroexpand-all (cdr form))))))))

(define-expander-for define-setf-expander (form)
  (let* ((accessor (second form))
         (lambda-list (third form))
         (body (cdddr form))
         (expander-fn (lambda (place)
                        (values-list
                         (funcall *macro-eval-fn*
                                  `(multiple-value-list
                                    ((lambda ,lambda-list ,@body) ',place)))))))
    (setf (gethash accessor *setf-compound-place-handlers*)
          (let ((fn expander-fn))
            (lambda (place value)
              (multiple-value-bind (temps vals stores store-form access-form)
                  (funcall fn place)
                (declare (ignore access-form))
                (compiler-macroexpand-all
                 (list 'let
                       (append (mapcar #'list temps vals)
                               (mapcar (lambda (s) (list s value)) stores))
                       store-form)))))))
  (list 'quote (second form)))

(define-expander-for defsetf (form)
  (let ((accessor (second form)))
    (cond
      ;; Short form: (defsetf accessor updater)
      ((and (= (length form) 3) (symbolp (third form)))
       (let ((updater (third form)))
         (setf (gethash accessor *setf-compound-place-handlers*)
               (lambda (place value)
                 (compiler-macroexpand-all
                  (cons updater (append (cdr place) (list value))))))))
      ;; Long form: (defsetf accessor (args...) (store-var) body...)
      ((and (>= (length form) 5) (listp (third form)) (listp (fourth form)))
       (let* ((lambda-list (third form))
              (store-vars (fourth form))
              (body (cddddr form))
              (store-var (first store-vars)))
         (setf (gethash accessor *setf-compound-place-handlers*)
               (let ((ll lambda-list) (sv store-var) (bd body))
                 (lambda (place value)
                    (let* ((arg-bindings (%normalize-let-bindings
                                          (generate-lambda-bindings ll place)))
                           (store-binding (list (list sv value))))
                     (compiler-macroexpand-all
                      (cons 'let
                            (cons (append arg-bindings store-binding)
                                  bd))))))))))
    (list 'quote accessor)))

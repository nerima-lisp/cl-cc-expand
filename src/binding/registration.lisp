(in-package :cl-cc/expand/binding)

(defvar *recursive-expander* nil)
(defvar *binding-expander-handlers* (make-hash-table :test #'eq))

(defun set-recursive-expander (function)
  (setf *recursive-expander* function))

(defun register-binding-expanders (register)
  (maphash register *binding-expander-handlers*))

(defun %expand-recursively (form)
  (unless *recursive-expander*
    (error "The binding feature has no recursive expander."))
  (funcall *recursive-expander* form))

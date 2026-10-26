(in-package :cl-cc/expand/binding)

;; let — destructuring bindings desugar to destructuring-bind chains; plain let expands values
;; FR-623: (let () body) → (progn body)
(progn
  (setf (gethash 'let *binding-expander-handlers*)
        (lambda (form)
          (%expand-let-form form))))

;; flet/labels — expand only function bodies; head symbol tells them apart
;; FR-623: (flet () body) / (labels () body) → (progn body)
(progn
  (setf (gethash 'flet *binding-expander-handlers*)
        (lambda (form)
          (%expand-flet-or-labels 'flet form))))

(progn
  (setf (gethash 'labels *binding-expander-handlers*)
        (lambda (form)
          (%expand-flet-or-labels 'labels form))))

;; apply — preserve final (list ...) spread so FR-044 codegen can lower it.
(progn
  (setf (gethash 'apply *binding-expander-handlers*)
        (lambda (form)
          (%expand-apply-form form))))

;; FR-585: handler-case :no-error clause
;; (handler-case form (type (v) ...) (:no-error (x) success-body))
;; → (block #:tag
;;     (let ((#:r (handler-case form (type (v) (return-from #:tag ...)))))
;;       success-body-with-x-bound))
(progn
  (setf (gethash 'handler-case *binding-expander-handlers*)
        (lambda (form)
          (%expand-handler-case-form form))))

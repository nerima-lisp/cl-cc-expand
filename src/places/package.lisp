(defpackage :cl-cc/expand/places
  (:use :cl)
  (:import-from :cl-cc/expand/expander
   #:define-expander-for #:our-defmacro #:register-macro #:compiler-macroexpand-all
   #:*setf-compound-place-handlers* #:*macro-eval-fn* #:expand-setf-accessor
   #:%build-setf-progn-forms #:%type-error-form)
  (:import-from :cl-cc/expand/binding #:generate-lambda-bindings #:%normalize-let-bindings)
  (:export #:*setf-compound-place-handlers* #:expand-setf-cons-place
           #:%type-error-form))

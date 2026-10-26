(defpackage :cl-cc/expand/clos
  (:use :cl)
  (:import-from :cl-cc/expand/expander
   #:*accessor-slot-map* #:define-expander-for #:register-macro #:compiler-macroexpand-all
   #:%expander-form #:expand-defclass-slot-spec #:register-defclass-accessors
   #:%defstruct-accessor-name #:%defstruct-make-keyword #:*defstruct-read-only-accessor-map*)
  (:import-from :cl-cc/expand/structures
   #:*defstruct-clos-expansion* #:%defstruct-copier-form #:%defstruct-make-constructor)
  (:export #:parse-float #:class-direct-default-initargs #:class-direct-slots
           #:class-direct-superclasses #:class-slots #:ensure-class
           #:generic-function-methods #:generic-function-method-combination
           #:class-precedence-list #:reinitialize-instance #:shared-initialize
           #:define-method-combination #:define-sealed-type #:change-class
           #:print-unreadable-object #:print-object #:describe-object #:describe))

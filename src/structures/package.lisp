(defpackage :cl-cc/expand/structures
  (:use :cl)
  (:import-from :cl-cc/expand/expander
   #:define-expander-for #:register-macro #:compiler-macroexpand-all
   #:*defstruct-slot-registry* #:*defstruct-type-registry* #:*defstruct-predicate-registry*
   #:*defstruct-read-only-accessor-map* #:*accessor-slot-map*
   #:*setf-compound-place-handlers* #:%defstruct-build-model #:%expander-form
   #:%defstruct-accessor-name #:%defstruct-make-keyword #:%defstruct-parse-slot
   #:%defstruct-find-option #:%defstruct-default-conc-name
   #:%defstruct-default-constructor-name #:%defstruct-default-predicate-name
   #:%defstruct-default-copier-name #:%defstruct-resolve-slot-values)
  (:export #:expand-defstruct #:*defstruct-clos-expansion*
           #:%defstruct-boa-bindings #:%defstruct-extract-boa-parts
           #:%defstruct-boa-param-names #:%defstruct-build-constructor
           #:%defstruct-build-model #:%defstruct-copy-form #:%defstruct-make-constructor
           #:%defstruct-copier-form #:%defstruct-typed-accessors
           #:%defstruct-typed-constructor #:%defstruct-typed-container-form
           #:%defstruct-typed-expansion-forms #:%defstruct-typed-predicate
           #:%defstruct-register-typed-accessors #:copy-structure))

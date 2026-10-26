(defpackage :cl-cc/expand/binding
  (:use :cl)
  (:export
   #:parse-lambda-list #:destructure-lambda-list #:generate-lambda-bindings
   #:*function-type-registry* #:register-function-type #:lambda-list-has-typed-p
   #:strip-typed-params #:lambda-list-info-environment #:expand-lambda-list-defaults
   #:set-recursive-expander #:register-binding-expanders #:*binding-expander-handlers*
   #:%expand-recursively #:%collapse-empty-binding-body
   #:expand-flet-labels-binding #:expand-let-binding
   #:%expand-apply-form #:%expand-flet-or-labels #:%expand-handler-case-form
   #:%expand-let-form #:%normalize-let-bindings
   #:lambda-list-info #:lambda-list-info-required #:lambda-list-info-optional
   #:lambda-list-info-rest #:lambda-list-info-key-params #:lambda-list-info-aux
   #:lambda-list-info-body #:lambda-list-info-whole #:lambda-list-info-allow-other-keys
   #:*lambda-list-keyword-transitions* #:*let-binding-expansion-stack*
   #:*compiler-local-function-names* #:*recursive-expander* #:%proper-list-p))

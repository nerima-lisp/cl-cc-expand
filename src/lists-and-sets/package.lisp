(defpackage :cl-cc/expand/lists-and-sets
  (:use :cl)
  (:import-from :cl-cc/expand/expander
   #:our-defmacro #:register-macro #:compiler-macroexpand-all #:string-concat)
  (:import-from :cl-cc/expand/sequences #:%sequence-dispatch-expand)
  (:export #:%expand-cxr #:%keyword-test-args #:%keyword-test-key-args #:%test-predicate-form))

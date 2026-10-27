(defpackage :cl-cc/expand/conditions
  (:use :cl)
  (:import-from :cl-cc/expand/expander
   #:our-defmacro
   #:register-macro)
  (:export #:*%condition-handlers* #:*%active-restarts*))

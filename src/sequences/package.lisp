(defpackage :cl-cc/expand/sequences
  (:use :cl)
  (:import-from :cl-cc/expand/expander #:our-defmacro #:register-macro #:compiler-macroexpand-all)
  (:export #:%sequence-dispatch-expand))

(defpackage :cl-cc/expand/expander/test
  (:use :cl :cl-cc-expand/test :cl-cc/expand/expander)
  (:shadowing-import-from :cl-cc/expand/expander #:compiler-macro-function)
  (:import-from :cl-cc/expand/expander #:foreign-funcall #:async-handler))
(in-package :cl-cc/expand/expander/test)

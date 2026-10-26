(defpackage :cl-cc/expand/control/test
  (:use :cl :cl-cc-expand/test :cl-cc/expand/control)
  (:shadowing-import-from :cl-cc/expand/control #:dolist #:dotimes #:do #:do* #:case #:typecase)
  (:import-from :cl-cc/expand/control #:defun/c))
(in-package :cl-cc/expand/control/test)

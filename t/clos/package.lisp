(defpackage :cl-cc/expand/clos/test
  (:use :cl :cl-cc-expand/test :cl-cc/expand/clos)
  (:shadowing-import-from :cl-cc/expand/clos #:change-class #:define-method-combination #:describe #:describe-object #:print-object #:print-unreadable-object #:reinitialize-instance #:shared-initialize))
(in-package :cl-cc/expand/clos/test)

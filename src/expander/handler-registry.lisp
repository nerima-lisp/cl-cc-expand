(in-package :cl-cc/expand/expander)

(defun register-expander-handler (head handler)
  (setf (gethash head *expander-head-table*) handler))

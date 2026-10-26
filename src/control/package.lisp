(defpackage :cl-cc/expand/control
  (:use :cl)
  (:import-from :cl-cc/expand/binding #:%collapse-empty-binding-body)
  (:import-from :cl-cc/expand/expander #:our-defmacro #:register-macro)
  (:export #:dolist #:dotimes #:do #:do* #:case #:typecase
           #:%case-build-eql-chain #:%case-collect-integer-pairs
           #:%typecase-build-typep-chain #:%typecase-choose-split-index
           #:%typecase-related-types-p))

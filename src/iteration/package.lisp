(defpackage :cl-cc/expand/iteration
  (:use :cl)
  (:import-from :cl-cc/expand/expander #:our-defmacro #:register-macro #:compiler-macroexpand-all)
  (:export #:loop #:make-iterator #:iterator-next #:with-iterator #:doiterator
           #:rt-use-package #:add-package-local-nickname
           #:*loop-acc-emitters* #:*loop-accum-keyword-table* #:*loop-boundary-keywords*
           #:*loop-condition-emitters* #:*loop-hash-iter-keywords* #:*loop-iter-emitters*
           #:*loop-using-keywords* #:*loop-vacuous-truth-conditions*
           #:finalize-loop-state #:loop-kw-member-p #:loop-kw-p
           #:lps-accumulations #:lps-body-forms #:lps-conditions #:lps-finally
           #:lps-initially #:lps-iterations #:lps-loop-name #:make-loop-parse-state
           #:parse-loop-clauses))

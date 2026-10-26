(in-package :cl-cc/expand/expander)

(set-recursive-expander #'compiler-macroexpand-all)
(register-binding-expanders #'register-expander-handler)

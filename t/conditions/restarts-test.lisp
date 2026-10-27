(in-package :cl-cc/expand/conditions/test)

(defsuite macros-restarts-suite
  :description "Restart protocol expansion tests"
  :parent cl-cc-unit-suite)

(in-suite macros-restarts-suite)

(deftest-each macros-restarts-control-expansion
  "Restart control forms expand to their expected top-level operators."
  :cases (("find-restart"    '(find-restart 'my-restart) 'let)
          ("invoke-restart"  '(invoke-restart 'my-restart) 'let*)
          ("abort"           '(abort)                      'let)
          ("restart-name"    '(restart-name r)             'if))
  (form expected-car)
  (assert-eq expected-car (car (our-macroexpand-1 form))))

(deftest macros-restarts-compute-restarts-expands
  "COMPUTE-RESTARTS expands to the active-restarts dynamic variable directly."
  (assert-eq 'cl-cc/expand/conditions::*%active-restarts* (our-macroexpand-1 '(compute-restarts))))
(deftest condition-handlers-symbol-is-imported-into-facade
  (let* ((name "*%CONDITION-HANDLERS*")
         (conditions-package (find-package :cl-cc/expand/conditions))
         (expand-package (find-package :cl-cc/expand))
         (symbol (find-symbol name conditions-package)))
    (assert-eq conditions-package (symbol-package symbol))
    (assert-eq :external (nth-value 1 (find-symbol name conditions-package)))
    (assert-eq symbol (find-symbol name expand-package))
    (assert-eq :internal (nth-value 1 (find-symbol name expand-package)))
    (assert-eq symbol (intern name expand-package))))
(deftest active-restarts-symbol-is-exported-from-facade
  (let* ((name "*%ACTIVE-RESTARTS*")
         (conditions-package (find-package :cl-cc/expand/conditions))
         (expand-package (find-package :cl-cc/expand))
         (symbol (find-symbol name conditions-package)))
    (assert-eq conditions-package (symbol-package symbol))
    (assert-eq :external (nth-value 1 (find-symbol name conditions-package)))
    (assert-eq symbol (find-symbol name expand-package))
    (assert-eq :external (nth-value 1 (find-symbol name expand-package)))))
(deftest handler-bind-and-signal-share-feature-registry
  (labels ((contains-symbol-p (tree symbol)
             (cond
               ((eq tree symbol) t)
               ((consp tree)
                (or (contains-symbol-p (car tree) symbol)
                    (contains-symbol-p (cdr tree) symbol)))
               (t nil)))
           (contains-operator-p (tree operator)
             (and (consp tree)
                  (or (eq (car tree) operator)
                      (contains-operator-p (car tree) operator)
                      (contains-operator-p (cdr tree) operator)))))
    (let* ((symbol (find-symbol "*%CONDITION-HANDLERS*"
                                :cl-cc/expand/conditions))
           (handler-expansion
             (our-macroexpand-1
               '(handler-bind ((error
                                (lambda (condition)
                                  (declare (ignore condition))
                                  :handled)))
                  :body)))
           (signal-expansion
             (our-macroexpand-1 '(signal "handled"))))
      (assert-true symbol)
      (assert-eq 'let (car handler-expansion))
      (assert-eq 'progv (car (third handler-expansion)))
      (assert-true (contains-operator-p handler-expansion 'append))
      (assert-true (contains-symbol-p handler-expansion symbol))
      (assert-eq 'let (car signal-expansion))
      (assert-eq 'dolist (car (third signal-expansion)))
      (assert-true (contains-operator-p signal-expansion 'funcall))
      (assert-true (contains-symbol-p signal-expansion symbol))
      (assert-eq nil (car (last signal-expansion))))))

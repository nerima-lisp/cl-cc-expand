;;;; LOOP clause expansion tests.

(in-package :cl-cc/expand/iteration/test)

;;;; :REPEAT and :WITH expansion structure

(check-loop-expansion loop-repeat-expansion-has-binding
  "repeat 4 binds an uninterned COUNT symbol initialized to 4 in let*."
  (repeat 4 collect t)
  (assert-eq 'block (car result))
  (assert-eq 'let* (car (caddr result)))
  (assert-true
   (some (lambda (binding)
           (and (symbolp (car binding))
                (null (symbol-package (car binding)))
                (let ((name (symbol-name (car binding))))
                  (and (>= (length name) 5)
                       (string= "COUNT" (subseq name 0 5))))
                (equal (cadr binding) 4)))
         (cadr (caddr result)))))

(check-loop-expansion loop-with-expansion-has-binding
  "with var = expr expansion includes the var binding in let*"
  (with x = 42 collect x)
  (assert-eq 'block (car result))
  (let ((bindings (cadr (caddr result))))
    (assert-true (member '(x 42) bindings :test #'equal))))

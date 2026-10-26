;;;; LOOP macro expansion tests.
;;;;
;;;; Covers generated structure for list and vector iteration, numeric
;;;; iteration, REPEAT, WHILE, INITIALLY, and FINALLY clauses.

(in-package :cl-cc/expand/iteration/test)

;;;; Helpers for expansion and error checks.
;;;;
;;;; Each helper expands to one test that uses only the macro expander.

(defmacro check-loop-expansion (name description clauses &body assertions)
  "LOOP structural test: macro-expand (loop ,@CLAUSES) then evaluate ASSERTIONS on the result."
  `(deftest ,name ,description
     (let ((result (our-macroexpand-1 '(loop ,@clauses))))
       ,@assertions)))

(defmacro check-loop-signals (name description clauses)
  "LOOP structural test: parsing CLAUSES must signal an error condition.
Exercises error paths in the parser and emitter layers."
  `(deftest ,name ,description
     (assert-signals error (our-macroexpand-1 '(loop ,@clauses)))))

;;;; Expansion structure

(check-loop-expansion loop-do-return-expands-to-block
  "A loop with a DO RETURN clause expands to a block."
  (do (return 42))
  (assert-true (consp result))
  (assert-eq 'block (car result))
  (assert-eq nil (cadr result)))

(check-loop-expansion loop-for-in-expands-to-let-tagbody
  "for x in list produces block → nil → let* containing tagbody."
  (for x in '(1 2 3) collect x)
  (assert-eq 'block (car result))
  (assert-eq nil (cadr result))
  (assert-eq 'let* (car (caddr result)))
  (assert-eq 'tagbody (car (car (cddr (caddr result))))))

(check-loop-expansion loop-from-to-expands-to-block
  "for i from 1 to 5 expands to block → nil → let*"
  (for i from 1 to 5 collect i)
  (assert-eq 'block (car result))
  (assert-eq nil (cadr result))
  (assert-eq 'let* (car (caddr result))))

(check-loop-expansion loop-repeat-has-counter-binding
  "repeat 3 binds an uninterned COUNT symbol initialized to 3."
  (repeat 3 collect t)
  (assert-true
   (some (lambda (binding)
           (and (symbolp (car binding))
                (null (symbol-package (car binding)))
                (let ((name (symbol-name (car binding))))
                  (and (>= (length name) 5)
                       (string= "COUNT" (subseq name 0 5))))
                (equal (cadr binding) 3)))
         (cadr (caddr result)))))

(check-loop-expansion loop-while-expands-to-block
  "while cond do ... expands to block"
  (while t do (return 1))
  (assert-eq 'block (car result)))

(check-loop-expansion loop-initially-finally-expands
  "initially/finally forms appear in the LET* body."
  (initially (print 'start) finally (print 'end) repeat 1)
  (let ((body (cddr (caddr result))))
    (assert-true (member '(print 'start) body :test #'equal))
    (assert-true (member '(print 'end) body :test #'equal))))

(check-loop-expansion loop-across-has-aref-and-length
  "for x across v expansion contains AREF and LENGTH"
  (for x across v collect x)
  (let ((s (format nil "~S" result)))
    (assert-true (search "AREF" s))
    (assert-true (search "LENGTH" s))))

(check-loop-expansion loop-across-has-four-bindings
  "across binds VEC, LEN, IDX, and ACC gensyms in that order."
  (for x across v collect x)
  (let ((bindings (cadr (caddr result))))
    (assert-true (= 4 (length bindings)))
    (assert-true
     (every (lambda (binding) (symbolp (car binding))) bindings))
    (assert-true
     (and (string= "VEC" (subseq (symbol-name (caar bindings)) 0 3))
          (string= "LEN" (subseq (symbol-name (caadr bindings)) 0 3))
          (string= "IDX" (subseq (symbol-name (caaddr bindings)) 0 3))
          (string= "ACC" (subseq (symbol-name (car (fourth bindings))) 0 3))))
    (assert-true
     (every (lambda (binding)
              (null (symbol-package (car binding))))
            bindings))
    (assert-eq 'v (cadar bindings))
    (assert-true
     (equal (list 'length (caar bindings))
            (cadr (second bindings))))
    (assert-= 0 (cadr (third bindings)))
    (assert-eq nil (cadr (fourth bindings)))
    (assert-true
     (member (list 'setq 'x
                   (list 'aref (caar bindings) (car (third bindings))))
             (cdr (car (cddr (caddr result))))
             :test #'equal))))

(in-package :cl-cc/expand/expander/test)

(defun %assert-export-surface ()
  (let* ((records
           (with-open-file (stream
                            (asdf:system-relative-pathname
                             "cl-cc-expand"
                             "t/export-surface.txt"))
             (let ((*read-eval* nil))
               (read stream))))
         (facade (find-package :cl-cc/expand))
         (expected-names (sort (mapcar #'sixth records) #'string<))
         (actual-names
           (sort (loop for symbol being the external-symbols of facade
                       collect (symbol-name symbol))
                 #'string<)))
    (assert-= 98 (length records))
    (assert-equal expected-names actual-names)
    (dolist (record records)
      (destructuring-bind (kind action facade-name feature-name home-name name
                           &optional changelog-reference)
          record
        (assert-eq :symbol kind)
        (assert-true (member action '(:keep :add)))
        (when (eq action :add)
          (assert-equal "CHANGELOG.md#expander-facade-exports" changelog-reference)
          (with-open-file
              (stream
               (asdf:system-relative-pathname "cl-cc-expand" "CHANGELOG.md"))
            (assert-true
             (loop for line = (read-line stream nil nil)
                   while line
                   thereis (string= line "## Expander facade exports")))))
        (multiple-value-bind (facade-symbol facade-status)
            (find-symbol name (string-upcase facade-name))
          (assert-eq :external facade-status)
          (multiple-value-bind (feature-symbol feature-status)
              (find-symbol name (string-upcase feature-name))
            (assert-eq :external feature-status)
            (assert-eq facade-symbol feature-symbol)
            (assert-true
             (string-equal
              home-name
              (package-name (symbol-package facade-symbol))))))))))

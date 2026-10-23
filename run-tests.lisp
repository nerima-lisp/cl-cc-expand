;;;; run-tests.lisp — run the ASDF test operation for cl-cc-expand/test.
;;;;
;;;; Bootstrap script: point ASDF's source registry at this checkout, then let
;;;; the inherited configuration resolve the dependencies. cl-cc-bootstrap,
;;;; cl-cc-type, cl-cc-vm, cl-host-kit (and their transitive closures), and
;;;; cl-weave must already be reachable through CL_SOURCE_REGISTRY, which
;;;; flake.nix exports for `nix flake check`, `nix run .#test` and the devShell.
;;;;
;;;; Usage: sbcl --script run-tests.lisp

(require :asdf)

(defun script-directory ()
  (make-pathname :name nil
                 :type nil
                 :defaults (or *load-truename*
                               *compile-file-truename*
                               (error "Unable to determine the script location"))))

(asdf:initialize-source-registry
 `(:source-registry
   (:tree ,(script-directory))
   :inherit-configuration))

(handler-case
    (progn
      (asdf:test-system "cl-cc-expand/test")
      (format t "~&RESULT: ALL PASS~%")
      (finish-output)
      (uiop:quit 0))
  (error (e)
    (format t "~&FAIL cl-cc-expand/test: ~a~%" e)
    (finish-output)
    (uiop:quit 1)))

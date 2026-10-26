;;;; t/expander/pbt/generators-cl-weave.lisp - Symbol generator on cl-weave
;;;
;;; Macro property tests use cl-weave 1.0.0's native combinators to generate
;;; fresh uninterned symbols. GEN-SYMBOL draws from a fixed :NAMES list
;;; ("x", "y", "value", "state"), which collides too often for tests that
;;; compare bindings by EQ. Generating names from GEN-INTEGER keeps values
;;; distinct while remaining a pure function of cl-weave's seeded RNG, so
;;; CL_WEAVE_PROPERTY_SEED reproduces a failing case exactly. The older helper
;;; called GENSYM, which leaked the global gensym counter into generation and
;;; made replay impossible.
;;;
;;; cl-weave ships GEN-SYMBOL, but it draws from a fixed :NAMES list
;;; ('("x" "y" "value" "state")), which collides far too often for tests that
;;; compare bindings by EQ. Generating the name from GEN-INTEGER instead keeps
;;; the values distinct while staying a pure function of cl-weave's seeded
;;; RNG — so CL_WEAVE_PROPERTY_SEED reproduces a failing case exactly. The
;;; home-grown version called GENSYM, which leaked the global gensym counter
;;; into generation and made replay impossible.

(in-package :cl-cc-expand/test)

(defun gen-pbt-symbol (prefix)
  "Generate a fresh uninterned symbol whose name is PREFIX plus a suffix."
  (cl-weave:gen-map (lambda (n) (make-symbol (format nil "~A-~D" prefix n)))
                    (cl-weave:gen-integer :min 0 :max 99999)
                    :name :pbt-symbol))


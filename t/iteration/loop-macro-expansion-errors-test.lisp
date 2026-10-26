;;;; LOOP clause expansion error tests.

(in-package :cl-cc/expand/iteration/test)

;;;; Error paths: unknown or malformed clause keywords
;;;;
;;;; These tests exercise the guard clauses in the parser and emitter layers.
;;;; Each check-loop-signals test verifies that an error is signalled rather
;;;; than silently producing wrong output.

(check-loop-signals loop-unknown-for-keyword-signals-error
  "FOR with an unrecognised sub-keyword signals an error"
  (for x sideways 10 collect x))

(check-loop-signals loop-being-unknown-hash-type-signals-error
  "BEING THE with an unrecognised hash-iteration keyword signals an error"
  (for k being the buckets of ht collect k))

(check-loop-signals loop-being-missing-of-signals-error
  "BEING THE HASH-KEYS without OF/IN signals an error"
  (for k being the hash-keys ht collect k))

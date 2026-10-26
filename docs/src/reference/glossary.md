This glossary describes feature implementation boundaries in this repository. A package name identifies the feature's implementation namespace; it does not imply every listed form is exported there. “Key types” and “Key functions” name exported symbols; “Key forms” lists forms implemented by the feature.

## expander

- Definition: The recursive macro expansion engine owns macro environments, expansion dispatch, caches, and the registrations shared by expansion features.
- Package: `cl-cc/expand/expander`
- Key types: `macro-env`
- Key functions: `make-macro-expander`, `our-macroexpand-1`, `our-macroexpand`, `our-macroexpand-all`, `compiler-macroexpand-all`, `register-macro`, `lookup-macro`
- Key forms: `our-defmacro`, `defun/c`, `define-syntax`, `syntax-rules`, `with-gensyms`, `once-only`

## binding

- Definition: Binding parses and destructures lambda lists, records typed parameter metadata, and prepares local binding forms for expansion.
- Package: `cl-cc/expand/binding`
- Key types: `lambda-list-info`
- Key functions: `parse-lambda-list`, `destructure-lambda-list`, `generate-lambda-bindings`, `register-function-type`, `strip-typed-params`, `lambda-list-info-environment`, `expand-lambda-list-defaults`, `set-recursive-expander`, `register-binding-expanders`

## control

- Definition: Control expands control-flow macros.
- Package: `cl-cc/expand/control`
- Key types: None.
- Key functions: None.
- Key forms: `dolist`, `dotimes`, `do`, `do*`, `case`, `typecase`

## conditions

- Definition: Conditions expands `handler-bind` and restart forms used by source programs.
- Package: `cl-cc/expand/conditions`
- Key types: None.
- Key functions: None.
- Key forms: `handler-bind`, `restart-case`, `restart-bind`, `with-simple-restart`, `invoke-restart`, `compute-restarts`

## iteration

- Definition: Iteration parses LOOP clauses, emits loop forms, and provides the iterator protocol.
- Package: `cl-cc/expand/iteration`
- Key types: None.
- Key functions: `make-iterator`, `iterator-next`, `rt-use-package`, `add-package-local-nickname`, `make-loop-parse-state`, `parse-loop-clauses`, `finalize-loop-state`
- Key forms: `loop`, `with-iterator`, `doiterator`

## structures

- Definition: Structures builds `defstruct` models and emits list- or vector-backed expansions, by-order-of-arguments (BOA) constructors, copiers, and default CLOS-backed expansions.
- Package: `cl-cc/expand/structures`
- Key types: None.
- Key functions: `expand-defstruct`

## places

- Definition: Places expands generalized assignment forms and registers compound-place handlers.
- Package: `cl-cc/expand/places`
- Key types: None.
- Key functions: `expand-setf-cons-place`

## clos

- Definition: CLOS expands class, generic-function, method, and Metaobject Protocol (MOP) forms for source programs.
- Package: `cl-cc/expand/clos`
- Key types: None.
- Key functions: `parse-float`
- Key forms: `class-direct-default-initargs`, `class-direct-slots`, `class-direct-superclasses`, `class-slots`, `ensure-class`, `generic-function-methods`, `generic-function-method-combination`, `class-precedence-list`, `reinitialize-instance`, `shared-initialize`, `define-method-combination`, `define-sealed-type`, `change-class`, `print-unreadable-object`, `print-object`, `describe-object`, `describe`

## sequences

- Definition: Sequences expands sequence operations and higher-order traversals over lists, vectors, and strings.
- Package: `cl-cc/expand/sequences`
- Key types: None.
- Key functions: `%sequence-dispatch-expand`
- Key forms: `map`, `map-into`, `reduce`, `search`, `position`, `count`

## io

- Definition: I/O expands filesystem and related runtime operations used by source programs.
- Package: `cl-cc/expand/io`
- Key types: None.
- Key functions: None.
- Key modules: `filesystem`

## lists-and-sets

- Definition: Lists and sets expands list, set, property-list, CXR, and introspection helpers.
- Package: `cl-cc/expand/lists-and-sets`
- Key types: None.
- Key functions: None.
- Key modules: `list-operations`, `setops`, `cxr`, `plist`, `introspection`

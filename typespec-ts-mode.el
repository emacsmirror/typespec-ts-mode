;;; typespec-ts-mode.el --- Emacs major mode for TypeSpec (using tree-sitter) -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 Pradyuman Vig
;;
;; Author: Pradyuman Vig <me@pmn.co>
;; Created: 19 January 2025
;; Modified: 20 January 2025
;; Version: 0.1
;; Package-Requires: ((emacs "29.1"))
;; Keywords: languages tree-sitter typespec
;; URL: https://github.com/pradyuman/typespec-ts-mode
;; SPDX-License-Identifier: MIT
;;
;; This file is NOT part of GNU Emacs.
;;
;;; Commentary:
;;
;; This package provides a major mode for editing TypeSpec files
;; using tree-sitter. It is compatible with the grammar at
;; https://github.com/happenslol/tree-sitter-typespec.
;;
;;; Code:

(require 'treesit)
(eval-when-compile (require 'cl-lib))
(eval-when-compile (require 'rx))

;;; Font lock
(defvar typespec-ts-mode--font-lock-feature-list
  '((comment definition)
    (keyword string type)
    (constant decorator directive namespace)
    (bracket delimiter property)))

(defvar typespec-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'typespec
   :feature 'bracket
   '(["(" ")" "[" "]" "{" "}"] @font-lock-bracket-face)

   :language 'typespec
   :feature 'comment
   '((single_line_comment) @font-lock-comment-face
     (multi_line_comment) @font-lock-comment-face)

   :language 'typespec
   :feature 'constant
   '([(decimal_literal) (hex_integer_literal) (binary_integer_literal)
      "true" "false" "null"] @font-lock-constant-face)

   :language 'typespec
   :feature 'decorator
   '((decorator
      "@" @font-lock-builtin-face
      name: (identifier_or_member_expression
             [(identifier) @font-lock-builtin-face
              (member_expression
               base: (identifier) @font-lock-builtin-face
               member: (identifier) @font-lock-builtin-face)]))
     (augment_decorator_statement
      "@@" @font-lock-builtin-face
      name: (identifier_or_member_expression
             [(identifier) @font-lock-builtin-face
              (member_expression
               base: (identifier) @font-lock-builtin-face
               member: (identifier) @font-lock-builtin-face)])))

   :language 'typespec
   :feature 'definition
   '((builtin_type) @font-lock-type-face
     (alias_statement name: (identifier) @font-lock-type-face)
     (enum_statement name: (identifier) @font-lock-type-face)
     (interface_statement name: (identifier) @font-lock-type-face)
     (model_statement name: (identifier) @font-lock-type-face)
     (operation_statement name: (identifier) @font-lock-function-name-face)
     (scalar_statement name: (identifier) @font-lock-type-face)
     (union_statement name: (identifier) @font-lock-type-face))

   :language 'typespec
   :feature 'delimiter
   '(["<" ">"] @font-lock-delimiter-face)

   :language 'typespec
   :feature 'directive
   '((directive
      "#" @font-lock-warning-face
      (identifier_or_member_expression
       [(identifier) @font-lock-warning-face
        (member_expression
         base: (identifier) @font-lock-warning-face
         member: (identifier) @font-lock-warning-face)])))

   :language 'typespec
   :feature 'escape
   '((escape_sequence) @font-lock-escape-face)

   :language 'typespec
   :feature 'keyword
   ;; https://github.com/microsoft/typespec/blob/main/packages/spec/src/spec.emu.html#L34
   '(["import" "model" "namespace" "op" "extends" "using" "interface" "union"
      "dec" "fn" "void" "never" "unknown" "alias" "enum" "scalar" "is"
      (decorator_modifiers) (function_modifiers)] @font-lock-keyword-face)

   :language 'typespec
   :feature 'namespace
   '((namespace_statement
      name: (identifier_or_member_expression
             [(identifier) @font-lock-function-name-face
              (member_expression
               base: (identifier) @font-lock-function-name-face
               member: (identifier) @font-lock-function-name-face)]))
     (using_statement
      module: (identifier_or_member_expression
               [(identifier) @font-lock-function-name-face
                (member_expression
                 base: (identifier) @font-lock-function-name-face
                 member: (identifier) @font-lock-function-name-face)])))

   :language 'typespec
   :feature 'property
   '((enum_member name: [(identifier) @font-lock-property-name-face])
     (model_property name: [(identifier) @font-lock-property-name-face])
     (union_variant name: (identifier) @font-lock-property-name-face))

   :language 'typespec
   :feature 'string
   '((quoted_string_literal) @font-lock-string-face
     (triple_quoted_string_literal) @font-lock-string-face)

   :language 'typespec
   :feature 'type
   '((template_parameter name: (identifier) @font-lock-type-face)
     (reference_expression
      ((identifier_or_member_expression
        [(identifier) @font-lock-type-face
         (member_expression
          base: (identifier) @font-lock-type-face
          member: (identifier) @font-lock-type-face)]))))))

(defun typespec-ts-mode--defun-name (node)
  (treesit-node-text (treesit-node-child-by-field-name node "name")))

;;;###autoload
(define-derived-mode typespec-ts-mode prog-mode "TypeSpec"
  "Major mode for editing TypeSpec files."
  :group 'typespec

  (unless (treesit-available-p)
    (error "Tree-sitter is not available"))

  (treesit-parser-create 'typespec)

  ;; Comments
  (setq-local comment-start "//"
              comment-end ""
              comment-start-skip (rx "//" (* (syntax whitespace))))

  ;; Font Lock
  (setq-local treesit-font-lock-feature-list typespec-ts-mode--font-lock-feature-list
              treesit-font-lock-settings typespec-ts-mode--font-lock-settings)

  ;; imenu
  (setq-local treesit-defun-name-function #'typespec-ts-mode--defun-name)
  (setq-local treesit-simple-imenu-settings
              `(("Alias" "\\`alias_statement\\'")
                ("Enum" "\\`enum_statement\\'")
                ("Interface" "\\`interface_statement\\'")
                ("Model" "\\`model_statement\\'")
                ("Operation" "\\`operation_statement\\'")
                ("Scalar" "\\`scalar_statement\\'")
                ("Union" "\\`union_statement\\'")))

  (treesit-major-mode-setup))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.tsp\\'" . typespec-ts-mode))

(provide 'typespec-ts-mode)
;;; typespec-ts-mode.el ends here

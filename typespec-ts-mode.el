;;; typespec-ts-mode.el --- Emacs major mode for TypeSpec (using tree-sitter) -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 Pradyuman Vig
;;
;; Author: Pradyuman Vig <me@pmn.co>
;; Created: 19 January 2025
;; Modified: 19 January 2025
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
  '((comment)))

(defvar typespec-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'typespec
   :feature 'comment
   '((single_line_comment) @font-lock-comment-face
     (multi_line_comment) @font-lock-comment-face)))

;;;###autoload
(define-derived-mode typespec-ts-mode prog-mode "TypeSpec"
  "Major mode for editing TypeSpec files."
  :group 'typespec

  (unless (treesit-available-p)
    (error "Tree-sitter is not available"))

  (treesit-parser-create 'typespec)

  ;; ;; Comments
  (setq-local comment-start "//"
              comment-end ""
              comment-start-skip (rx "//" (* (syntax whitespace))))

  (setq-local treesit-font-lock-feature-list typespec-ts-mode--font-lock-feature-list
              treesit-font-lock-settings typespec-ts-mode--font-lock-settings)

  (font-lock-mode 1)

  (treesit-major-mode-setup))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.tsp\\'" . typespec-ts-mode))

(provide 'typespec-ts-mode)
;;; typespec-ts-mode.el ends here

;;; package --- Emacs configuration using use-package

;;; Commentary:

;;; Code:

(require 'use-package)

;; Remove UI clutter
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Move backup files to dedicated directory
(setq backup-directory-alist '(("." . "~/.config/emacs/backups")))

;; Which-key - show available keybindings
(use-package which-key
  :config
  (which-key-mode)
  ;; Only show prefix keys
  (setq which-key-show-prefix 'bottom))

;; Evil mode - Vim emulation
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1))

;; Evil collection - Evil bindings for many modes
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Company - text completion
(use-package company
  :config
  (global-company-mode))

;; LSP mode - Language Server Protocol support
(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((tuareg-mode . lsp)
         (typescript-mode . lsp)
         (js2-mode . lsp)
         (python-mode . lsp))
  :commands lsp)

;; LSP UI - UI improvements for LSP
(use-package lsp-ui
  :commands lsp-ui-mode)

;; YASnippet - template system
(use-package yasnippet
  :config
  (yas-global-mode 1))

;; Flycheck - syntax checking
(use-package flycheck
  :config
  (global-flycheck-mode))

;; Magit popup - needed for Guix development
(use-package magit-popup)

;; Magit - Git interface
(use-package magit
  :bind ("C-x g" . magit-status))

;; Guix interface
(use-package guix
  :after magit-popup)

;; Projectile - project interaction
(use-package projectile
  :init
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map))

;; Undo-fu - better undo for Evil mode
(use-package undo-fu
  :after (evil)
  :config
  (evil-set-undo-system 'undo-fu))

;; General - keybinding framework
(use-package general
  :after (evil)
  :config
  (general-auto-unbind-keys t)
  (general-evil-setup t))

;; Helm - completion framework
(use-package helm
  :config
  (helm-mode 1)
  (setq helm-split-window-in-side-p t)
  (setq helm-move-to-line-cycle-in-source t)
  (setq helm-ff-search-library-in-sexp t)
  (setq helm-scroll-amount 4)
  (setq helm-ff-file-name-history-use-recentf t))

;; Configure projectile to use helm for completion
(with-eval-after-load 'projectile
  (setq projectile-completion-system 'helm))


;; OCaml support
(use-package tuareg
  :mode ("\\.ml\\'" . tuareg-mode))

;; TypeScript support
(use-package typescript-mode
  :mode "\\.ts\\'")

;; JavaScript support
(use-package js2-mode
  :mode "\\.js\\'")

;; JSX support
(use-package rjsx-mode
  :mode "\\.jsx\\'")

;; Prettier - code formatter
(use-package prettier
  :hook ((typescript-mode . prettier-mode)
         (js2-mode . prettier-mode)
         (rjsx-mode . prettier-mode)))

;; Python virtual environment support
(use-package pyvenv)

;; Scheme support
(use-package geiser)
(use-package geiser-guile
  :config
  (setq geiser-default-implementation 'guile)
  ;; Add guix paths to exec-path so Emacs can find guile
  (add-to-list 'exec-path "/home/john/Profiles/system/bin")
  (add-to-list 'exec-path "/home/john/.guix-profile/bin"))

;; Load custom configurations
(load-file (expand-file-name "keybindings.el" user-emacs-directory))
(let ((splash-file (expand-file-name "splash.el" user-emacs-directory)))
  (message "Loading splash.el from: %s" splash-file)
  (if (file-exists-p splash-file)
      (load-file splash-file)
    (message "splash.el not found at: %s" splash-file)))

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(helm-minibuffer-history-key "M-p")
 '(safe-local-variable-values
   '((eval modify-syntax-entry 43 "'") (eval modify-syntax-entry 36 "'")
     (eval modify-syntax-entry 126 "'")
     (lisp-fill-paragraphs-as-doc-string nil)
     (geiser-insert-actual-lambda) (geiser-repl-per-project-p . t)
     (eval with-eval-after-load 'yasnippet
	   (let
	       ((guix-yasnippets
		 (expand-file-name "etc/snippets/yas"
				   (locate-dominating-file
				    default-directory ".dir-locals.el"))))
	     (unless (member guix-yasnippets yas-snippet-dirs)
	       (add-to-list 'yas-snippet-dirs guix-yasnippets)
	       (yas-reload-all))))
     (eval with-eval-after-load 'tempel
	   (if (stringp tempel-path)
	       (setq tempel-path (list tempel-path)))
	   (let
	       ((guix-tempel-snippets
		 (concat
		  (expand-file-name "etc/snippets/tempel"
				    (locate-dominating-file
				     default-directory
				     ".dir-locals.el"))
		  "/*.eld")))
	     (unless (member guix-tempel-snippets tempel-path)
	       (add-to-list 'tempel-path guix-tempel-snippets))))
     (eval with-eval-after-load 'git-commit
	   (add-to-list 'git-commit-trailers "Change-Id"))
     (eval setq-local guix-directory
	   (locate-dominating-file default-directory ".dir-locals.el"))
     (eval add-to-list 'completion-ignored-extensions ".go"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

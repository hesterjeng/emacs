;;; init.el --- Emacs configuration using use-package  -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'use-package)

;; Add all Guix Emacs packages to load-path
(let ((guix-site-lisp (expand-file-name "~/.guix-profile/share/emacs/site-lisp")))
  (when (file-directory-p guix-site-lisp)
    (add-to-list 'load-path guix-site-lisp)
    (dolist (dir (directory-files guix-site-lisp t "^[^.]"))
      (when (file-directory-p dir)
        (add-to-list 'load-path dir)))))

;; Remove UI clutter
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Smooth scrolling
(pixel-scroll-precision-mode 1)
(setq scroll-conservatively 101)
(setq scroll-margin 3)

;; Move backup files to dedicated directory
(setq backup-directory-alist '(("." . "~/.config/emacs/backups")))

;; Which-key - show available keybindings
(use-package which-key
  :config
  (which-key-mode)
  ;; Only show prefix keys
  (setq which-key-show-prefix 'bottom))

;; Smart mode line - cleaner, more informative modeline
(use-package smart-mode-line
  :ensure nil  ; Already installed via Guix
  :config
  (setq sml/no-confirm-load-theme t)
  (setq sml/theme 'respectful)
  (sml/setup))

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
  ;; We use Guix, not opam: invoke the ocamllsp binary directly instead of
  ;; the default "opam exec -- ocamllsp" wrapper, which fails with no opam.
  (setq lsp-ocaml-lsp-server-command '("ocamllsp"))
  ;; Don't start lsp in read-only Guix store / profile / findlib dirs. Jumping to
  ;; a library definition (M-.) lands in a store `.ml`; if lsp booted a *second*
  ;; server rooted there, it has no dune-project/.merlin and can't resolve
  ;; anything — that desync is what caused the "no document found ... didChange"
  ;; loop. Library type/nav still works via THIS project's server, which already
  ;; has all the store build paths baked into its dune .merlin-conf, so the buffer
  ;; you land in just doesn't need its own server.
  ;; Use `lsp-deferred', not `lsp': it opens the document on the server only once
  ;; the buffer is actually current, avoiding the didOpen/didChange race (server
  ;; gets an edit for a URI it never saw opened) that shows up as repeated
  ;; "no document found with uri: ...".
  (defun my/lsp-unless-readonly-lib ()
    "Start `lsp-deferred' unless visiting a read-only Guix store/profile library file."
    (unless (and buffer-file-name
                 (string-match-p "/gnu/store/\\|/\\.guix-profile/\\|/site-lib/"
                                 buffer-file-name))
      (lsp-deferred)))
  :hook ((tuareg-mode . my/lsp-unless-readonly-lib)
         (typescript-mode . lsp)
         (js2-mode . lsp)
         (python-mode . lsp))
  :commands (lsp lsp-deferred))

;; LSP UI - UI improvements for LSP
(use-package lsp-ui
  :commands lsp-ui-mode)

;; YASnippet - template system
(use-package yasnippet
  :config
  (yas-global-mode 1))

;; Community snippet collection (must load before/with yasnippet's dir scan)
(use-package yasnippet-snippets
  :after yasnippet)

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

;; diff-hl - show git added/changed/deleted lines in the fringe
(use-package diff-hl
  :config
  (global-diff-hl-mode)
  ;; Refresh indicators live in dired and immediately after Magit commits
  (add-hook 'dired-mode-hook #'diff-hl-dired-mode)
  (with-eval-after-load 'magit
    (add-hook 'magit-pre-refresh-hook #'diff-hl-magit-pre-refresh)
    (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)))

;; rainbow-delimiters - depth-colored parens, invaluable for lisp/scheme/ocaml
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; hl-todo - highlight TODO/FIXME/HACK/NOTE keywords in comments
(use-package hl-todo
  :config
  (global-hl-todo-mode))

;; editorconfig - honor a repo's .editorconfig (indent style, width, etc.)
(use-package editorconfig
  :config
  (editorconfig-mode 1))

;; ws-butler - trim trailing whitespace, but only on lines you actually edited
(use-package ws-butler
  :hook (prog-mode . ws-butler-mode))

;; Envrc - direnv integration (buffer-local environments)
(use-package envrc
  :config
  (envrc-global-mode))

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

;; Evil surround - cs"' , ysiw) , ds( etc. to manipulate delimiters
(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

;; Evil nerd commenter - gc (operator), gcc (current line), gc in visual.
;; NOTE: we deliberately do NOT call `evilnc-default-hotkeys', which would
;; steal C-c l and C-c p globally (our lsp-keymap-prefix and projectile map).
(use-package evil-nerd-commenter
  :after evil
  :commands (evilnc-comment-operator evilnc-copy-and-comment-operator)
  :config
  (evil-define-key '(normal visual) 'global
    "gc" #'evilnc-comment-operator          ; gcc = current line (operator doubling)
    "gy" #'evilnc-copy-and-comment-operator))

;; Helm - completion framework
(use-package helm
  :config
  (helm-mode 1)
  (setq helm-split-window-in-side-p t)
  (setq helm-move-to-line-cycle-in-source t)
  (setq helm-ff-search-library-in-sexp t)
  (setq helm-scroll-amount 4)
  (setq helm-ff-file-name-history-use-recentf t))

;; Helm + LSP: fuzzy-jump to any symbol in the LSP workspace
(use-package helm-lsp
  :after (helm lsp-mode)
  :commands helm-lsp-workspace-symbol
  :config
  ;; Replace lsp-mode's default xref symbol search with the helm UI
  (with-eval-after-load 'lsp-mode
    (define-key lsp-mode-map [remap xref-find-apropos]
                #'helm-lsp-workspace-symbol)))

;; Helm-ag: fast project-wide search backed by ripgrep
(use-package helm-ag
  :after helm
  :commands (helm-ag helm-do-ag helm-do-ag-project-root)
  :init
  (setq helm-ag-base-command "rg --no-heading --line-number --color never"))

;; Let helm-mode (enabled above) handle projectile's completing-read via the
;; compatible completing-read-function path. Projectile's own 'helm branch
;; calls `helm' with an argument layout current helm rejects
;; ("Initial input should be a string or nil"), so use 'default here.
(with-eval-after-load 'projectile
  (setq projectile-completion-system 'default))

;; OCaml support
(use-package tuareg
  :mode (("\\.ml[ily]?\\'" . tuareg-mode)
         ("\\.topml\\'" . tuareg-mode)))

;; Merlin - OCaml context-sensitive completion and navigation
(use-package merlin
  :ensure nil  ; Already installed via Guix
  :hook (tuareg-mode . merlin-mode)
  :config
  ;; Disable opam usage - rely on dune-generated .merlin files
  (setq merlin-command "ocamlmerlin")
  (setq merlin-use-opam-switch nil)
  ;; Enable company completion with Merlin
  (with-eval-after-load 'company
    (add-to-list 'company-backends 'merlin-company-backend))
  ;; Use Merlin for imenu
  (setq merlin-use-auto-complete-mode nil))

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

;; Markdown - make prose render clean and readable instead of raw text+color
(use-package markdown-mode
  :ensure nil  ; Already installed via Guix (emacs-markdown-mode)
  :mode (("README\\.md\\'" . gfm-mode)   ; GitHub-flavored for READMEs
         ("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init
  ;; Used only for C-c C-c export/preview; harmless if pandoc isn't installed.
  (setq markdown-command "pandoc")
  :config
  ;; Fontify fenced code blocks with the target language's own font-lock.
  (setq markdown-fontify-code-blocks-natively t)
  ;; Hide the raw markup (**, _, `, #) once it's styled. This variable is
  ;; buffer-local (make-variable-buffer-local in markdown-mode), so it MUST be
  ;; set with setq-default here — a plain `setq' would only touch whatever
  ;; buffer is current at load time and never affect real markdown buffers.
  ;; Toggle live with `C-c C-x C-m' (markdown-toggle-markup-hiding) to edit.
  (setq-default markdown-hide-markup t)
  ;; Also hide inline URLs behind their link text for cleaner prose.
  (setq-default markdown-hide-urls t)
  ;; Bigger, bolder headings that step down in size like a rendered document.
  (setq markdown-header-scaling t
        markdown-header-scaling-values '(1.7 1.5 1.3 1.15 1.05 1.0))
  (markdown-update-header-faces markdown-header-scaling
                                markdown-header-scaling-values)
  ;; Proportional body text + soft-wrapped lines = document, not source code.
  (defun my/markdown-prose-look ()
    "Give Markdown buffers a readable, document-like appearance."
    (variable-pitch-mode 1)           ; proportional font for prose
    (visual-line-mode 1)              ; wrap long lines at word boundaries
    (setq-local line-spacing 0.15)    ; a little breathing room between lines
    ;; Force markup hiding on for this buffer (bulletproof against reloads and
    ;; buffers opened before the default took effect); refontifies to apply it.
    (markdown-toggle-markup-hiding 1)
    ;; Centered, fixed-width reading column so text isn't smushed against the
    ;; left edge on a wide monitor. Body width is a fraction of the window.
    (when (require 'olivetti nil t)
      (setq-local olivetti-body-width 0.72)
      (olivetti-mode 1))
    ;; Wrapped continuation lines (under bullets, numbered items, blockquotes)
    ;; indent to align with their content instead of the left margin.
    (when (require 'adaptive-wrap nil t)
      (setq-local adaptive-wrap-extra-indent 2)
      (adaptive-wrap-prefix-mode 1))
    ;; Keep anything that must stay monospaced (code, tables) fixed-pitch.
    (dolist (face '(markdown-code-face
                    markdown-inline-code-face
                    markdown-pre-face
                    markdown-table-face
                    markdown-language-keyword-face))
      (face-remap-add-relative face :inherit 'fixed-pitch)))
  (add-hook 'markdown-mode-hook #'my/markdown-prose-look))

;; Dumb-jump - go-to-definition using ripgrep/ag/grep
(use-package dumb-jump
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  (setq dumb-jump-prefer-searcher 'rg)
  (setq dumb-jump-selector 'helm))

;; Scheme support
(use-package geiser
  :config
  (setq geiser-active-implementations '(guile))
  (setq geiser-default-implementation 'guile))

(use-package geiser-guile
  :after geiser
  :config
  (setq geiser-guile-binary "guile")
  (setq geiser-guile-load-path
        (list (expand-file-name "~/Projects/guix"))))

;; Load custom configurations AFTER all packages
(with-eval-after-load 'evil-collection
  (load-file (expand-file-name "keybindings.el" user-emacs-directory)))
(let ((splash-file (expand-file-name "splash.el" user-emacs-directory)))
  (message "Loading splash.el from: %s" splash-file)
  (if (file-exists-p splash-file)
      (load-file splash-file)
    (message "splash.el not found at: %s" splash-file)))

;; gptel - direct LLM chat (requires API key)
(use-package gptel
  :config
  (gptel-make-anthropic "Claude"
    :stream t
    :key (lambda () (getenv "ANTHROPIC_API_KEY"))))

;; Claude Code IDE - bidirectional Emacs/Claude Code bridge via MCP
(use-package claude-code-ide
  :ensure nil
  :commands (claude-code-ide claude-code-ide-menu claude-code-ide-resume
             claude-code-ide-continue claude-code-ide-send-prompt)
  :config
  (claude-code-ide-emacs-tools-setup)
  ;; Open as regular buffer, not a side window
  (setq claude-code-ide-use-side-window nil)
  ;; Ediff: hide Claude window during diff + keep focus on diff controls
  (setq claude-code-ide-show-claude-window-in-ediff nil
        claude-code-ide-focus-claude-after-ediff nil)
  ;; Batch render updates at 1s — skip spinner/progress animation entirely
  (setq claude-code-ide-vterm-render-delay 1.0)
  ;; Fix ambiguous-width Unicode chars (spinners/bullets) that cause flicker
  (defun claude-code-ide--fix-char-widths ()
    "Set Claude's spinner and bullet characters to single width."
    (let ((table (make-char-table nil)))
      (dolist (char '(#x2722 #x2733 #x2217 #x273B #x273D #x23FA))
        (set-char-table-range table char 1))
      (set-char-table-parent table char-width-table)
      (setq-local char-width-table table)))
  (add-hook 'vterm-mode-hook #'claude-code-ide--fix-char-widths)
  ;; Disable scroll-margin in vterm to prevent buffer jumping back
  (defun claude-code-ide--fix-vterm-scrolling ()
    "Disable settings that cause erratic scrolling in vterm buffers."
    (setq-local scroll-margin 0)
    (setq-local scroll-conservatively 0)
    (setq-local pixel-scroll-precision-mode nil))
  (add-hook 'vterm-mode-hook #'claude-code-ide--fix-vterm-scrolling)
  ;; Limit scrollback so old output doesn't cause lag/jumping
  (setq vterm-max-scrollback 512)
  ;; Make C-c C-l actually clear scrollback, not just the visible screen
  (defun claude-code-ide--clear-scrollback ()
    "Clear vterm scrollback buffer completely."
    (interactive)
    (vterm-clear-scrollback)
    (vterm-clear))
  (add-hook 'vterm-mode-hook
            (lambda ()
              (local-set-key (kbd "C-c C-l") #'claude-code-ide--clear-scrollback))))

;; agent-shell - native buffer AI agent via ACP (no vterm)
(use-package agent-shell
  :ensure nil
  :commands (agent-shell agent-shell-new-shell agent-shell-toggle
             agent-shell-send-region agent-shell-send-file
             agent-shell-send-dwim agent-shell-prompt-compose)
  :custom
  ;; Skip agent selection — always use Claude Code
  (agent-shell-preferred-agent-config
   (agent-shell-anthropic-make-claude-code-config))
  ;; Ask whether to resume or start fresh each time
  (agent-shell-session-strategy 'prompt)
  ;; Use viewport (richer overlay-based view) as primary interaction
  (agent-shell-prefer-viewport-interaction nil)
  ;; Collapse thinking/tool-use by default to reduce noise
  (agent-shell-thought-process-expand-by-default nil)
  (agent-shell-tool-use-expand-by-default nil)
  ;; Syntax highlight code blocks in responses (minor perf cost)
  (agent-shell-highlight-blocks t)
  ;; Interactive permission approval (nil = always prompt)
  ;; Set to #'agent-shell-permission-allow-always for YOLO mode
  (agent-shell-permission-responder-function nil)
  ;; Confirm before interrupting a running request
  (agent-shell-confirm-interrupt t)
  :config
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t))
  ;; Fix: strip text properties from history ring before writing.
  ;; shell-maker uses `buffer-substring' (not -no-properties) when
  ;; extracting history, so keymaps/font-lock/cursor-sensor closures
  ;; from agent-shell-ui links get serialized into the history file
  ;; via prin1, producing unreadable garbage on restore.
  (defun agent-shell--strip-history-properties (config)
    "Strip text properties from comint-input-ring entries before save."
    (when (ring-p comint-input-ring)
      (let ((vec (cddr comint-input-ring)))
        (dotimes (i (length vec))
          (when (stringp (aref vec i))
            (aset vec i (substring-no-properties (aref vec i))))))))
  (advice-add 'shell-maker--write-input-ring-history
              :before #'agent-shell--strip-history-properties)
  ;; Evil-friendly: RET inserts newline, M-RET submits
  (evil-define-key 'insert agent-shell-mode-map
    (kbd "RET") #'newline
    (kbd "M-<return>") #'shell-maker-submit)
  (evil-define-key 'normal agent-shell-mode-map
    (kbd "RET") #'agent-shell-ui-toggle-fragment-at-point
    (kbd "TAB") #'agent-shell-next-item
    (kbd "<backtab>") #'agent-shell-previous-item
    (kbd "]]") #'agent-shell-next-item
    (kbd "[[") #'agent-shell-previous-item)
  ;; Viewport view mode: use Emacs state so single-letter keys (r, y, f, b,
  ;; n, p, etc.) reach the viewport keymap instead of being eaten by Evil.
  (evil-set-initial-state 'agent-shell-viewport-view-mode 'emacs)
  ;; Viewport edit mode: Evil insert state for composing prompts
  (evil-set-initial-state 'agent-shell-viewport-edit-mode 'insert)
  ;; Diff mode: use Emacs state so single-letter keys (n, p, y, f, q)
  ;; reach agent-shell-diff-mode-map instead of being eaten by Evil.
  ;; Also remove evil-collection's read-only state switcher which would
  ;; override the initial state back to motion.
  (evil-set-initial-state 'agent-shell-diff-mode 'emacs)
  (add-hook 'agent-shell-diff-mode-hook
            (lambda ()
              (remove-hook 'read-only-mode-hook
                           #'evil-collection-diff-read-only-state-switch t))))

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

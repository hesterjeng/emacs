;;; keybindings.el --- Custom keybindings configuration using general.el

;;; Commentary:
;; Custom SPC leader key bindings using general.el

;;; Code:

(require 'general)

  ;; Use direct key binding instead
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)


;; Create SPC leader key
(general-create-definer my/leader-keys
  :states '(normal insert visual emacs)
  :keymaps 'override
  :prefix "SPC"
  :global-prefix "C-SPC")

;; Define SPC leader bindings
(my/leader-keys
  ;; Files
  "f" '(:ignore t :which-key "files")
  "ff" 'find-file
  "fr" 'recentf-open-files
  "fs" 'save-buffer
  "fS" 'save-some-buffers
  "fd" 'delete-file
  "fR" 'rename-file
  "fc" 'copy-file
  
  ;; Buffers
  "b" '(:ignore t :which-key "buffers")
  "bb" 'switch-to-buffer
  "bd" 'kill-buffer
  "bn" 'next-buffer
  "bp" 'previous-buffer
  "br" 'revert-buffer
  "bN" '(lambda () (interactive) (switch-to-buffer (generate-new-buffer "untitled")))
  "bR" 'rename-buffer
  "bs" 'save-buffer
  "bS" 'save-some-buffers
  "bi" 'ibuffer
  "bk" 'kill-current-buffer
  "ba" 'mark-whole-buffer
  "be" 'eval-buffer
  
  ;; Git (magit)
  "g" '(:ignore t :which-key "git")
  "gg" 'magit-status
  "gb" 'magit-blame
  "gl" 'magit-log
  "gf" 'magit-file-dispatch
  "gc" 'magit-commit
  "gp" 'magit-push
  "gP" 'magit-pull
  "gd" 'magit-diff
  "gs" 'magit-stage-file
  "gu" 'magit-unstage-file
  
  ;; Project (projectile)
  "p" '(:ignore t :which-key "project")
  "pp" 'projectile-switch-project
  "pf" 'projectile-find-file
  "pg" 'projectile-grep
  "pb" 'projectile-switch-to-buffer
  "pk" 'projectile-kill-buffers
  
  ;; Window management
  "w" '(:ignore t :which-key "window")
  "ww" 'other-window
  "wd" 'delete-window
  "ws" 'split-window-below
  "wv" 'split-window-right
  "wn" 'split-window-right
  "wo" 'delete-other-windows
  "wh" 'windmove-left
  "wj" 'windmove-down
  "wk" 'windmove-up
  "wl" 'windmove-right
  
  ;; Code/LSP
  "c" '(:ignore t :which-key "code")
  "cd" 'lsp-find-definition
  "cr" 'lsp-find-references
  "cf" 'lsp-format-buffer
  "ca" 'lsp-execute-code-action
  "ci" 'lsp-find-implementation
  "ct" 'lsp-find-type-definition
  
  ;; Search
  "s" '(:ignore t :which-key "search")
  "ss" 'isearch-forward
  "sp" 'projectile-grep
  "sg" 'grep
  
  ;; Quit/restart
  "q" '(:ignore t :which-key "quit")
  "qq" 'save-buffers-kill-terminal
  "qr" 'restart-emacs
  "qQ" 'kill-emacs)

;; Override Geiser's gd binding to use evil-goto-definition (xref/dumb-jump)
(with-eval-after-load 'geiser-mode
  (evil-define-key 'normal geiser-mode-map (kbd "g d") 'evil-goto-definition))

(provide 'keybindings)
;;; keybindings.el ends here

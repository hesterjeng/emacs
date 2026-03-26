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
  "bd" 'kill-current-buffer
  "bn" 'next-buffer
  "bp" 'previous-buffer
  "br" 'revert-buffer
  "bN" '(lambda () (interactive) (switch-to-buffer (generate-new-buffer "untitled")))
  "bR" 'rename-buffer
  "bs" 'save-buffer
  "bS" 'save-some-buffers
  "bi" 'ibuffer
  "bk" 'kill-buffer
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
  "ct" 'lsp-describe-thing-at-point
  
  ;; Search
  "s" '(:ignore t :which-key "search")
  "ss" 'isearch-forward
  "sp" 'projectile-grep
  "sg" 'grep
  
  ;; AI (Agent Shell)
  "a" '(:ignore t :which-key "ai")
  "aa" 'agent-shell
  "an" 'agent-shell-new-shell
  "at" 'agent-shell-toggle
  "ai" '((lambda () (interactive)
           (if (derived-mode-p 'agent-shell-viewport-view-mode)
               (agent-shell-viewport-interrupt)
             (agent-shell-interrupt)))
          :which-key "interrupt")
  ;; Send context
  "as" 'agent-shell-send-region
  "af" 'agent-shell-send-file
  "ad" 'agent-shell-send-dwim
  "aS" 'agent-shell-send-screenshot
  ;; Session
  "am" 'agent-shell-set-session-model
  "aM" 'agent-shell-set-session-mode
  "aq" '(agent-shell-queue-request :which-key "queue request")
  "ar" 'agent-shell-resume-pending-requests
  ;; Permissions
  "ap" 'agent-shell-jump-to-latest-permission-button-row
  ;; Compose / transcripts / other
  "ab" '((lambda () (interactive)
           (let ((bufs (agent-shell-buffers)))
             (if bufs
                 (switch-to-buffer
                  (completing-read "Agent shell: "
                                   (mapcar #'buffer-name bufs) nil t))
               (user-error "No agent shell buffers"))))
          :which-key "agent shell buffers")
  "ac" 'agent-shell-prompt-compose
  "ao" 'agent-shell-open-transcript
  "av" 'agent-shell-other-buffer
  "aw" 'agent-shell-new-worktree-shell
  "ah" 'agent-shell-help-menu
  ;; Session management
  "aF" 'agent-shell-fork
  "aR" 'agent-shell-restart
  "ax" 'agent-shell-remove-pending-request
  "aC" 'agent-shell-cycle-session-mode
  "aI" 'agent-shell-copy-session-id
  "ay" 'agent-shell-yank-dwim
  ;; Debugging
  "al" 'agent-shell-toggle-logging
  "aL" 'agent-shell-view-acp-logs

  ;; Mic/Whisper
  "m" '(:ignore t :which-key "mic")
  "mm" 'whisper-start
  "mq" 'whisper-stop

  ;; Quit/restart
  "q" '(:ignore t :which-key "quit")
  "qq" 'save-buffers-kill-terminal
  "qr" 'restart-emacs
  "qQ" 'kill-emacs)

;; Whisper transcription
(defvar whisper-transcribe-script "~/Projects/whisper/transcribe.sh")
(defvar whisper--buffer-name "*whisper*")

(defun whisper-start ()
  "Start whisper transcription recording."
  (interactive)
  (if (get-buffer whisper--buffer-name)
      (message "Whisper is already recording!")
    (let ((buf (make-comint-in-buffer "whisper" whisper--buffer-name
                                       whisper-transcribe-script)))
      (set-process-sentinel (get-buffer-process buf)
                            (lambda (proc _event)
                              (when (not (process-live-p proc))
                                (let ((buf (process-buffer proc)))
                                  (when (buffer-live-p buf)
                                    (let ((win (get-buffer-window buf)))
                                      (when win (delete-window win)))
                                    (kill-buffer buf))))))
      (display-buffer buf
                      '(display-buffer-at-bottom . ((window-height . 5))))
      (message "Whisper recording started..."))))

(defun whisper-stop ()
  "Stop whisper transcription by sending m."
  (interactive)
  (let ((proc (get-buffer-process whisper--buffer-name)))
    (if proc
        (progn
          (comint-send-string proc "\n")
          (message "Whisper stopping..."))
      (message "No whisper process running."))))

;; Override Geiser's gd binding to use evil-goto-definition (xref/dumb-jump)
(with-eval-after-load 'geiser-mode
  (evil-define-key 'normal geiser-mode-map (kbd "g d") 'evil-goto-definition))

(provide 'keybindings)
;;; keybindings.el ends here

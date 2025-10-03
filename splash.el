;;; splash.el --- Dashboard configuration

;;; Commentary:
;; Configuration for Emacs dashboard with centering

;;; Code:

;; Dashboard package for a better startup screen
(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  ;; Center content horizontally and vertically
  (setq dashboard-center-content t)
  (setq dashboard-vertically-center-content t)
  ;; Basic configuration
  (setq dashboard-banner-logo-title "Welcome to Emacs")
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-items '((recents  . 5)
                         (bookmarks . 5)
                         (projects . 5)))
  ;; Remove unnecessary info
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-show-shortcuts nil))

(provide 'splash)
;;; splash.el ends here
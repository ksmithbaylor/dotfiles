; Use the ~/.emacs.d directory for backup and autosave files
(defvar backup-dir (expand-file-name "backup/" user-emacs-directory))
(defvar autosave-dir (expand-file-name "autosave/" user-emacs-directory))
(setq backup-directory-alist (list (cons ".*" backup-dir)))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))

; General appearance and behavior
(menu-bar-mode -1)
(setq inhibit-startup-screen t)

(provide 'init-settings)

(add-hook 'neotree-mode-hook
  (lambda ()
    (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter)))

(global-set-key [f8] 'neotree-toggle)

(provide 'init-neotree)

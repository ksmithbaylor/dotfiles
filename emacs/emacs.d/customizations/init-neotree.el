(add-hook 'neotree-mode-hook
	  (lambda ()
	    (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter)))

(provide 'init-neotree)

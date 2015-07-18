; Enumerate package sources and initialize the package manager
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))
(package-initialize)

; Install necessary packages
(setq my-packages '(
            evil
            js2-mode
            ruby-end
            ))

(unless package-archive-contents
  (package-refresh-contents))

(dolist (pkg my-packages)
  (when (and (not (package-installed-p pkg))
           (assoc pkg package-archive-contents))
    (package-install pkg)))

(provide 'init-packages)

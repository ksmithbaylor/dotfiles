; Load my customizations
(add-to-list 'load-path
             (concat user-emacs-directory
                     (convert-standard-filename "customizations/")))

; General editor config and customization
(require 'init-packages)
;(require 'init-evil)
(require 'init-theme)
(require 'init-editing)
(require 'init-settings)
(require 'init-neotree)

; Per-language customizations
(require 'custom-javascript)
(require 'custom-ruby)

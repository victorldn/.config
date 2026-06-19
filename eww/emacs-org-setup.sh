#!/bin/bash
mkdir -p ~/org
touch ~/org/inbox.org
touch ~/org/tasks.org

# Add to emacs config:
# (setq org-directory "~/org")
# (setq org-agenda-files '("~/org/inbox.org"
#                          "~/org/tasks.org"))

emacs --daemon

emacsclient -e '(+ 1 2)'

emacsclient -e "(setq org-directory \"~/org\")"
emacsclient -e "(setq org-agenda-files '(\"~/org/inbox.org\" \
                         \"~/org/tasks.org\"))"
emacsclient -e "(require 'org-id)"

emacsclient -e \
	    "(setq org-capture-templates \
      	    	   '((\"t\" \"Todo\" \
      	    	   entry \
         	   (file \"~/org/inbox.org\") \
         	   \"* TODO %?\n%U\")))"

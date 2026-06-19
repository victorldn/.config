;; -*- lexical-binding: t; -x*-
(require 'org)
(require 'org-id)
(require 'json)

(setq org-agenda-files '("~/org/inbox.org" "~/org/tasks.org"))

(defun eww-org-format-date (date)
  (if (or (null date) (string= date "-"))
      "-"
    (let* ((time (org-time-string-to-time date))
           (today (time-to-days (current-time)))
           (due-day (time-to-days time))
           (days (- due-day today)))
      (cond
       ((= days 0) "today")
       ((= days 1) "tomorrow")
       ((< days 0) "overdue")
       ((<= days 7) (format "%dd" days))
       (t (format-time-string "%d %b" time))))))

(defun eww-org-escape (s)
  (json-encode-string (or s "")))

(defun eww-org-collect-todos ()
  (let (items)
    (dolist (file org-agenda-files)
      (with-current-buffer (find-file-noselect file)
        (org-map-entries
         (lambda ()
           (let* ((todo (org-get-todo-state))
                  (title (org-get-heading t t t t))
                  (id (org-id-get-create))
                  (deadline (org-entry-get nil "DEADLINE"))
                  (scheduled (org-entry-get nil "SCHEDULED"))
                  (date (eww-org-format-date (or deadline scheduled "-"))))
             (push (list id title date file) items)))
         "TODO=\"TODO\"")))
    (nreverse items)))

(defun eww-org-render-todos ()
  (let ((items (eww-org-collect-todos)))
    (princ "(box :orientation \"vertical\" :class \"todo-table\"\n")
    (princ "  (box :orientation \"horizontal\" :class \"todo-row todo-header\" :space-evenly false\n")
    (princ "    (label :class \"todo-due\" :width 60 :text \"DATE\")\n")
    (princ "    (label :class \"todo-desc\" :hexpand true :xalign 0 :text \"TASK\")\n")
    (princ "    (label :class \"todo-actions-spacer\" :text \"\"))\n")

    (dolist (item items)
      (pcase-let ((`(,id ,title ,date ,file) item))
        (princ "  (box :orientation \"horizontal\" :class \"todo-row\" :space-evenly false\n")
        (princ (format "    (label :class \"todo-due\" :width 60 :text %s)\n"
                       (eww-org-escape date)))
        (princ (format "    (label :class \"todo-desc\" :hexpand true :xalign 0 :text %s)\n"
                       (eww-org-escape title)))
	(princ (format  "    (button :class \"todo-select-button\" :onclick \"eww update active_task_id='%s' active_task_desc='%s'\" \"›\")\n"
			id
			title))
        (princ (format "    (button :class \"todo-done-button\" :onclick \"~/.config/eww/scripts/org-task-action.sh done %s\" \"✓\")\n"
                       id))
        (princ "  )\n")))
    (princ ")\n")))

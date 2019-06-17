(load-file "robot/robot.el")
(load-file "org-drill.el")

(defun org-drill-do-drill ()
  (copy "main-test.org" "main-test-copy.org")
  (find "main-test-copy.org")

  (org-drill)
  (set-buffer-modified-p nil)
  (kill-buffer))

(org-drill-do-drill)

(message "First drill complete")

(setq org-drill-presentation-prompt-with-typing t)

(org-drill-do-drill)

(robot-check-cards-seen-and-die 6)

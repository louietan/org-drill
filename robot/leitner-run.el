(load-file "robot/robot.el")
(load-file "org-drill.el")

(copy "leitner-run.org" "leitner-run-copy.org")
(find "leitner-run-copy.org")

(org-drill-leitner)
(set-buffer-modified-p nil)
(kill-buffer)


(robot-check-cards-seen-and-die 3)

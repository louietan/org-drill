(load-file "robot/robot.el")
(load-file "org-drill.el")

(copy "all-card.org" "all-card-copy.org")
(find "all-card-copy.org")

(org-drill)

(robot-check-cards-seen-and-die
 (string-to-number
  (car command-line-args-left)))

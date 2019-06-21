(load-file "robot/robot.el")
(load-file "org-drill.el")

(copy "spanish-robot.org" "spanish-robot-copy.org")
(find "spanish-robot-copy.org")

;; bump this up so we do everything
(setq org-drill-maximum-items-per-session 40)

(org-drill)


(robot-check-cards-seen-and-die 15)

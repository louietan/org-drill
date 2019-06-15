;; Shutup
(setq make-backup-files nil)
(setq auto-save-default nil)

(setq top-dir default-directory)

;; Clean up
(delete-file (concat top-dir "robot/failure.txt"))
(delete-file (concat top-dir "robot/messages.txt"))

(set-frame-name "emacs-bot")

(setq debug-on-error t)
(setq debug-on-quit t)

(defun die ()
  (interactive)
  (kill-emacs)
  )

(defun dump-buffer (buffer file)
  (save-excursion
    (when (get-buffer buffer)
      (set-buffer buffer)
      (write-region (point-min) (point-max)
                    (concat top-dir "robot/" file)
                    nil 'dont-display-wrote-file-message
                    ))))

(add-hook 'debugger-mode-hook
          'org-drill-launcher-dump-in-a-bit)

(defun org-drill-launcher-dump-in-a-bit ()
  (run-with-timer 1 nil #'org-drill-launcher-dump))

(defun org-drill-dump-messages ()
  (dump-buffer "*Messages*" "messages.txt"))

(run-with-timer 1 1 #'org-drill-dump-messages)


(defun org-drill-launcher-dump ()
  (dump-buffer "*Backtrace*" "failure.txt")
  (dump-buffer "*Messages*" "messages.txt")
  (kill-emacs -1)
  )

(load-file "org-drill.el")

(defun org-drill-do-drill ()
  (copy-file "robot/main-test.org" "robot/main-test-copy.org" t)
  (find-file "robot/main-test-copy.org")

  (org-drill)
  (set-buffer-modified-p nil)
  (kill-buffer))

(org-drill-do-drill)

(message "First drill complete")

(setq org-drill-presentation-prompt-with-typing t)

(org-drill-do-drill)

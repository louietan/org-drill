;; Shutup
(setq make-backup-files nil)
(setq auto-save-default nil)

(setq top-dir default-directory)

(set-frame-name "emacs-bot")

(setq debug-on-error t)
(setq debug-on-quit t)

(defun clean (file)
  (delete-file (concat top-dir "robot/" file)))

;; Clean up
(clean "failure.txt")
(clean "messages.txt")

(defun die ()
  (interactive)
  (kill-emacs))

(defun dump-buffer (buffer file)
  (save-excursion
    (when (get-buffer buffer)
      (set-buffer buffer)
      (write-region (point-min) (point-max)
                    (concat top-dir "robot/" file)
                    nil 'dont-display-wrote-file-message
                    ))))


(add-hook 'debugger-mode-hook
          'robot-dump-in-a-bit)

(defun robot-dump-in-a-bit ()
  (run-with-timer 1 nil #'robot-dump))

(defun robot-dump ()
  (dump-buffer "*Backtrace*" "failure.txt")
  (dump-buffer "*Messages*" "messages.txt")
  (kill-emacs -1))

(defun robot-dump-messages ()
  (dump-buffer "*Messages*" "messages.txt"))

(run-with-timer 1 1 #'robot-dump-messages)

(defun robot-check-cards-seen-and-die (n)
  (if (= n org-drill-cards-in-this-emacs)
      (progn
        (princ
         (format "Succeeded: Saw %s cards as expected\n" n)
         'external-debugging-output)
        (kill-emacs 0))
    (princ
     (format "Failed: Saw %s cards, expecting %s\n"
             org-drill-cards-in-this-emacs n)
     'external-debugging-output)
    (kill-emacs -1)))

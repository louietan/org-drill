;; Shutup
(setq make-backup-files nil)
(setq auto-save-default nil)

;; Clean up
(delete-file "./robot/failure.txt")

(set-frame-name "emacs-bot")

(condition-case e
    (load-file "org-drill.el")
  (error
   (with-temp-buffer
     (insert (format "%s" (error-message-string e)))
     (write-region (point-min) (point-max) "./robot/failure.txt"))
   (let ((kill-emacs-hook nil))
     (kill-emacs))))

(copy-file "robot/main-test.org" "robot/main-test-copy.org" t)
(find-file "robot/main-test-copy.org")

(condition-case e
    (org-drill)
  (error
   (with-temp-buffer
     (insert (format "%s" (error-message-string e)))
     ;; write to ./ now because we have changed directory
     (write-region (point-min) (point-max) "./failure.txt"))
   (let ((kill-emacs-hook nil))
     (kill-emacs))))

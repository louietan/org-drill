;; Shutup
(setq make-backup-files nil)
(setq auto-save-default nil)

(setq top-dir default-directory)

;; Clean up
(delete-file (concat top-dir "robot/failure.txt"))

(set-frame-name "emacs-bot")

(setq debug-on-error t)
(setq debug-on-quit t)

(add-hook 'debugger-mode-hook
          'org-drill-launcher-dump-in-a-bit)
(defun org-drill-launcher-dump-in-a-bit ()
  (run-with-timer 1 nil #'org-drill-launcher-dump))

(defun org-drill-launcher-dump ()
  (save-excursion
    (set-buffer "*Backtrace*")
    (write-region (point-min) (point-max) (concat top-dir "robot/failure.txt")))
  (kill-emacs))

(load-file "org-drill.el")

(copy-file "robot/main-test.org" "robot/main-test-copy.org" t)
(find-file "robot/main-test-copy.org")

(org-drill)

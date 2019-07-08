;; Shutup
(setq make-backup-files nil)
(setq auto-save-default nil)

(setq top-dir default-directory)

(set-frame-name "emacs-bot")

(setq debug-on-error t)
(setq debug-on-quit t)

(defun robot-file (file)
  (concat top-dir "robot/" file))

(defun clean (file)
  (delete-file (robot-file file)))

(defun copy (from to)
  (copy-file (robot-file from) (robot-file to) t))

(defun find (file)
  (find-file (robot-file file)))

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
                    nil 'dont-display-wrote-file-message))))

(add-hook 'debugger-mode-hook
          'robot-dump-in-a-bit)

(defun robot-dump-in-a-bit ()
  (run-with-timer 1 nil #'robot-dump))

(defun robot-dump ()
  (dump-buffer "*Backtrace*" "failure.txt")
  (dump-buffer "*Messages*" "messages.txt")
  (princ "Killing Emacs after error\n"
         'external-debugging-output)
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

;; Move the package-user-dir somewhere local
(require 'package)
(setq package-user-dir
      (concat
       default-directory
       "elpa"))

(package-initialize)

;; Borrowed from use-package
(defun robot-ensure-elpa (package &optional no-refresh)
  (if (package-installed-p package)
      t
    (if (and (not no-refresh))
        (package-read-all-archive-contents))
    (if (or (assoc package package-archive-contents) no-refresh)
        (package-install package)
      (progn
        (package-refresh-contents)
        (robot-ensure-elpa package t)))))

(robot-ensure-elpa 'persist)

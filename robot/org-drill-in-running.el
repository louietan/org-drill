(setq top-dir default-directory)

(defun org-drill-bot ()
  (interactive)
  (copy-file (concat top-dir "main-test.org")
             (concat top-dir "main-test-interactive-copy.org") t)
  (find-file (concat top-dir "main-test-interactive-copy.org"))
  (org-drill)
  (set-buffer-modified-p))

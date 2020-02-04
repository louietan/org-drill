;;; org-drill-anki.el --- Anki's SM2 variation porting to org-drill  -*- lexical-binding: t; -*-
;;
;; Author: Lei Tan
;; Version: 0.1
;; URL: https://github.com/louietan/org-drill
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(require 'cl-lib)
(require 'org-drill)

(defgroup org-drill-anki nil
  "Customization options for anki's SM2 algorithm."
  :tag "Org-Drill-Anki"
  :group 'org-drill)

(defcustom org-drill-anki-starting-easiness
  2.5
  "Starting ease factor."
  :group 'org-drill
  :type 'float)

(defcustom org-drill-anki-learning-steps
  '(1 10)
  "Steps for learnig cards (in minutes)."
  :group 'org-drill
  :type '(repeat integer))

(defcustom org-drill-anki-easy-bonus
  1.3
  "Easy bonus."
  :group 'org-drill
  :type 'float)

(defcustom org-drill-anki-interval-modifer
  1.0
  "Interval modifier."
  :group 'org-drill
  :type 'float)

(defcustom org-drill-anki-graduating-interval
  1
  "Graduating interval."
  :group 'org-drill
  :type 'integer)

(defcustom org-drill-anki-easy-interval
  4
  "Easy interval."
  :group 'org-drill
  :type 'integer)

(defcustom org-drill-anki-lapse-steps
  '(10)
  "Learning steps for relearning cards (in minutes)."
  :group 'org-drill
  :type '(repeat integer))

(defcustom org-drill-anki-lapse-new-interval-factor
  0.0
  "New interval."
  :group 'org-drill
  :type 'float)

(defcustom org-drill-anki-lapse-minimum-interval
  1
  "Minimum interval in days."
  :group 'org-drill
  :type 'integer)

(defcustom org-drill-anki-maximum-interval
  36500
  "Maximum interval in days."
  :group 'org-drill
  :type 'integer)

(defun org-drill-random-int (min max)
  "Return a random integer between MIN and MAX inclusively."
  (if (= min max)
      min
    (+ min (cl-random (1+ (- max min))))))

(defsubst org-drill-anki--delays (status)
  (or (cl-case status
        ((:new :learning) org-drill-anki-learning-steps)
        (t org-drill-anki-lapse-steps))
      '(1)))

(defun org-drill-anki--reps-left-today (delays left)
  "Calculate reps left today with DELAYS and reps LEFT till graduating.

Ref: _leftToday"
  (let ((delays (last delays left))
        (cutoff (time-add
                 (date-to-time (format-time-string "%Y-%m-%d 00:00:00"))
                 (days-to-time 1))))
    (cl-loop with time = (current-time)
             for i from 0
             for d in delays
             do (cl-callf time-add time (seconds-to-time (* 60 d)))
             until (time-less-p cutoff time)
             finally return i)))

(defun org-drill-anki--initial-reps (status)
  "Calculate initial reps for an learning entry of STATUS.

Ref: _startingLeft"
  (let* ((delays (org-drill-anki--delays status))
         (total (length delays)))
    (list (org-drill-anki--reps-left-today delays total) total)))

(defun org-drill-anki--fuzz-interval-range (interval)
  "Return an fuzzed interval range (MIN . MAX) on INTERVAL.

Ref: _fuzzIvlRange"
  (cond
   ((< interval 2) '(1 . 1))
   ((= interval 2) '(2 . 3))
   (t
    (let ((fuzz (thread-first (cond
                               ((< interval 7) (* interval 0.25))
                               ((< interval 30) (max 2 (* interval 0.15)))
                               (t (max 4 (* interval 0.05))))
                  (truncate)
                  ;; fuzzz at least a day
                  (max 1))))
      (cons (- interval fuzz) (+ interval fuzz))))))

(defun org-drill-anki--fuzz-interval (interval)
  "Return a randomized interval on INTERVAL.

Ref: _fuzzedIvl"
  (destructuring-bind (min . max)
      (org-drill-anki--fuzz-interval-range interval)
    (org-drill-random-int min max)))

(cl-defmethod org-drill-add-noise-to-interval (interval)
  (min (org-drill-anki--fuzz-interval interval) org-drill-anki-maximum-interval))

(defun org-drill-anki--interval-to-string (interval)
  "Format INTERVAL in a readable style, INTERVAL is days if positive, minutes if negative."
  (cond
   ((< interval 0) (org-drill-anki--interval-to-string (abs (/ interval 1440.0))))
   ((< interval (/ 60 1440.0)) (format "%dm" (* 1440 interval)))
   ((< interval 1) (format "%.1fh" (/ (* 1440 interval) 60)))
   ((< interval 30) (format "%dd" interval))
   ((< interval 365) (format "%.1fmo" (/ interval 31.0)))
   (t (format "%.1fy" (/ interval 365.0)))))

(defsubst org-drill-anki--lapse-new-interval (last-interval)
  (max org-drill-anki-lapse-minimum-interval
       (* last-interval org-drill-anki-lapse-new-interval-factor)))

(defsubst org-drill-anki--review-new-interval (last-interval ef quality days-late)
  "Ref: _nextRevIvl"
  (cl-assert (and (<= 2 quality) (<= quality 4)))
  (cl-flet ((fix-interval (ivl last) (max (1+ last)
                                          (* ivl org-drill-anki-interval-modifer))))
    (let* ((i2 (fix-interval (* 1.2 (+ last-interval (/ days-late 4))) last-interval))
           (i3 (fix-interval (* ef (+ last-interval (/ days-late 2))) i2))
           (i4 (fix-interval (* ef org-drill-anki-easy-bonus (+ last-interval days-late)) i3))
           (interval (cl-case quality
                       (2 i2)
                       (3 i3)
                       (4 i4))))
      (min interval org-drill-anki-maximum-interval))))

(cl-defmethod org-drill-answer-buttons (&context
                                        (org-drill-spaced-repetition-algorithm (eql sm2-anki))
                                        &optional
                                        status)
  "Ref: answerButtons"
  (cl-case status
    ((:new :learning) '(?1 ?2 ?3))
    (:relearning (if (< 1 (length org-drill-anki-lapse-steps))
                     '(?1 ?2 ?3)
                   '(?1 ?2)))
    (t '(?1 ?2 ?3 ?4))))

(cl-defmethod org-drill-key-prompt (&context
                                    (org-drill-spaced-repetition-algorithm (eql sm2-anki))
                                    &key
                                    _key next-review-dates buttons _status)
  (format "%s, %c=edit, %c=tags, %c=quit"
          (apply #'format
                 (cl-ecase (length buttons)
                   (2 "1=Again (%s), 2=Good (%s)")
                   (3 "1=Again (%s), 2=Good (%s), 3=Easy (%s)")
                   (4 "1=Again (%s), 2=Hard (%s), 3=Good (%s), 4=Easy (%s)"))
                 (cl-loop for i below (length buttons)
                          collect (org-drill-anki--interval-to-string
                                   (nth i next-review-dates))))
          org-drill--edit-key
          org-drill--tags-key
          org-drill--quit-key))

(cl-defmethod org-drill-hypothetical-next-review-dates (status
                                                        buttons
                                                        &context
                                                        (org-drill-spaced-repetition-algorithm (eql sm2-anki)))
  (cl-loop for b in buttons
           collect (org-drill-hypothetical-next-review-date status (- b ?0))))

(cl-defmethod org-drill-determine-next-interval (&context
                                                 (org-drill-spaced-repetition-algorithm (eql sm2-anki))
                                                 &key
                                                 quality last-interval ease status
                                                 failures meanq repeats-since-fail
                                                 total-repeats reps-left due
                                                 &allow-other-keys)
  "Returns a list: (INTERVAL REPEATS EF FAILURES MEAN TOTAL-REPEATS OF-MATRIX REPS-LEFT)."
  (when (null ease) (setq ease org-drill-anki-starting-easiness))
  (when (null meanq) (setq meanq 0))
  (when (null reps-left) (setq reps-left '(0 0)))
  (let (delays delay interval)
    (cl-case status
      ;; unseen or learning
      ((:new :learning :relearning)
       (setq delays (org-drill-anki--delays status))
       (cl-case quality
         ;; easy, graduate early
         (3 (setq reps-left '(0 0))
            (cl-case status
              (:relearning (setq interval (org-drill-anki--lapse-new-interval last-interval)))
              (t (setq ease org-drill-anki-starting-easiness
                       interval (org-drill-anki--fuzz-interval org-drill-anki-easy-interval)))))
         ;; good
         (2 (when (eq :new status)
              (setq reps-left (org-drill-anki--initial-reps status)))
            ;; one step towards graduation
            (cl-decf (cl-second reps-left))
            (if (zerop (cl-second reps-left))
                ;; graduate
                (cl-case status
                  (:relearning (setq interval (org-drill-anki--lapse-new-interval last-interval)))
                  (t (setq ease org-drill-anki-starting-easiness
                           interval (org-drill-anki--fuzz-interval org-drill-anki-graduating-interval))))
              ;; next step
              (setf delay (cl-first (last delays (cl-second reps-left)))
                    (cl-first reps-left) (org-drill-anki--reps-left-today delays (cl-second reps-left)))))
         ;; again, reset steps
         (1 (setq delays (org-drill-anki--delays status)
                  reps-left (org-drill-anki--initial-reps status)
                  delay (cl-first (last delays (cl-second reps-left)))))))
      ;; review
      (t (cond
          ((> quality 1)
           (setq interval (org-drill-anki--review-new-interval
                           last-interval ease quality
                           (max 0
                                (truncate
                                 (time-to-number-of-days
                                  (time-subtract (current-time) due)))))
                 ease (max 1.3 (+ ease (nth (- quality 2) '(-0.15 0 0.15))))))
          ;; failed
          (t
           (setq failures (1+ failures)
                 repeats-since-fail 0
                 ease (max 1.3 (- ease 0.2))
                 delays org-drill-anki-lapse-steps
                 reps-left (org-drill-anki--initial-reps status)
                 delay (cl-first (last delays (cl-second reps-left))))))))
    (when delay
      (setq interval (* delay (/ (org-drill-random-int 100 125) -100.0))))
    (list interval
          (1+ repeats-since-fail)
          ease
          failures
          meanq
          (1+ total-repeats)
          org-drill-sm5-optimal-factor-matrix
          reps-left)))

(defun org-drill-peek-learning-entry (session)
  (cl-find-if
   (lambda (m)
     (time-less-p (gethash m (oref session learning-data))
                  (current-time)))
   (oref session learning-entries)))

(cl-defmethod org-drill-entries-pending-p (session
                                           &context (org-drill-spaced-repetition-algorithm (eql sm2-anki)))
  (or (and (oref session learning-entries)
           (org-drill-peek-learning-entry session))
      (oref session current-item)
      (and (not (org-drill-maximum-item-count-reached-p session))
           (not (org-drill-maximum-duration-reached-p session))
           (or (oref session new-entries)
               (oref session prior-entries)
               (oref session young-mature-entries)
               (oref session old-mature-entries)
               (oref session overdue-entries)
               (and (oref session learning-entries)
                    (org-drill-peek-learning-entry session))))))

(cl-defmethod org-drill-pop-learning-entry (session
                                            &context (org-drill-spaced-repetition-algorithm (eql sm2-anki)))
  (when-let (((oref session learning-entries))
             (entry (org-drill-peek-learning-entry session)))
    (cl-delete entry (oref session learning-entries))
    entry))

(cl-defmethod org-drill-entry-done-p (&context
                                      (org-drill-spaced-repetition-algorithm (eql sm2-anki))
                                      &key _quality)
  ;; an entry is done when there's no reps left today
  (zerop (cl-first (org-drill-entry-reps-left))))

(cl-defmethod org-drill-final-report (session
                                      &context
                                      (org-drill-spaced-repetition-algorithm (eql sm2-anki)))
  (let* ((qualities (oref session qualities))
         (pass-percent
          (round (* 100 (cl-count-if (lambda (qual)
                                       (> qual (org-drill-failure-quality)))
                                     qualities))
                 (max 1 (length qualities))))
         (prompt nil)
         (max-mini-window-height 0.6))
    (setq prompt
          (format
           "%d items reviewed. Session duration %s.
You successfully recalled %d%% of reviewed items.
%d/%d items still await review (%s, %s, %s, %s, %s).
Session finished. Press a key to continue..."
           (length (oref session done-entries))
           (format-seconds "%h:%.2m:%.2s"
                           (- (float-time (current-time))
                              (oref session start-time)))
           pass-percent
           (org-drill-pending-entry-count session)
           (+ (org-drill-pending-entry-count session)
              (oref session dormant-entry-count))
           (propertize
            (format "%d re/learning"
                    (+ (length (oref session prior-entries))
                       (length (oref session learning-entries))))
            'face `(:foreground ,org-drill-failed-count-color))
           (propertize
            (format "%d overdue"
                    (length (oref session overdue-entries)))
            'face `(:foreground ,org-drill-failed-count-color))
           (propertize
            (format "%d new"
                    (length (oref session new-entries)))
            'face `(:foreground ,org-drill-new-count-color))
           (propertize
            (format "%d young"
                    (length (oref session young-mature-entries)))
            'face `(:foreground ,org-drill-mature-count-color))
           (propertize
            (format "%d old"
                    (length (oref session old-mature-entries)))
            'face `(:foreground ,org-drill-mature-count-color))))

    (while (not (input-pending-p))
      (message "%s" prompt)
      (sit-for 0.5))
    (read-char-exclusive)))

(provide 'org-drill-anki)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; org-drill-anki.el ends here

;;; org-drill-test.el

;;; Header:

;; This file is not part of Emacs

;; Author: Phillip Lord <phillip.lord@russet.org.uk>
;; Maintainer: Phillip Lord <phillip.lord@russet.org.uk>

;; The contents of this file are subject to the GPL License, Version 3.0.

;; Copyright (C) 2019, Phillip Lord

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Code:

(require 'assess)
(require 'org-drill)

(defvar this-directory
  (file-name-directory
   (or load-file-name (buffer-file-name))))

(ert-deftest load-test ()
  (should t))

(ert-deftest find-entries ()
  (should
   (equal '(2 38 66)
	  (assess-with-find-file
              (assess-make-related-file
               (concat this-directory "one-two-three.org"))
            (org-drill-map-entries (lambda () (point)) 'file nil)))))

(ert-deftest find-tagged-entries ()
  (should
   (equal '(2)
	  (assess-with-find-file
           (assess-make-related-file
            (concat this-directory "one-two-three.org"))
           (org-drill-map-entries (lambda () (point)) 'file "tagtest")))))

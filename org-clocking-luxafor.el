;;; org-clocking-luxafor.el --- Change the colour of Luxafor LEDs when clocking in/out in org-mode -*- coding: utf-8 -*-

;; Copyright (C) 2016 onwards Iñaki Arenaza

;; Author: Iñaki Arenaza <iarenaza@escomposlinux.org>
;; Version: 0.2
;; Created: 2016.12.23
;; Package-Requires: ((emacs "24.3") (org-mode "8.0"))
;; Keywords: org-mode clock, luxafor
;; URL: https://github.com/iarenaza/org-clocking-luxafor.git

;; This file is not part of GNU Emacs.

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

;;; Commentary:

;; This package provides functions to change the colour of Luxafor
;; LEDs.  The functions are supposed to be called from 'org-mode'
;; clock-in and clock-out hooks.
;;
;; To use the package, require it first:
;;
;;     (require 'org-clocking-luxafor)
;;
;; Or if you didn't install it in the load path, specify the path
;; to the elisp file.  E.g:
;;
;;     (require 'org-clocking-luxafor "~/lisp-code/org-clocking-luxafor.el")
;;
;; Them simply hook the clock-in and clock-out functions to the
;; 'org-mode' clock-in and clock-out hooks:
;;
;;     (add-hook 'org-clock-in-hook #'org-clocking-luxafor-clock-in)
;;     (add-hook 'org-clock-out-hook #'org-clocking-luxafor-clock-out)

;;; Code:

(require 'cl-lib)

(defgroup org-clocking-luxafor nil
  "Change the colour of Luxafor LEDs when clocking in/out in org-mode"
  :prefix "org-clocking-luxafor-"
  :group 'applications
  :link '(url-link :tag "GitHub" "https://github.com/iarenaza/org-clocking-luxafor")
  :link '(emacs-commentary-link :tag "Commentary" "org-clocking-luxafor"))

;; Some of the usual Luxafor patterns.
(defcustom org-clocking-luxafor-patterns
  '((off                . "\x01\xff\x00\x00\x00\x00\x00\x00")
    ;;
    (red                . "\x01\xff\xff\x00\x00\x00\x00\x00")
    (green              . "\x01\xff\x00\xff\x00\x00\x00\x00")
    (blue               . "\x01\xff\x00\x00\xff\x00\x00\x00")
    (yellow             . "\x01\xff\xff\xff\x00\x00\x00\x00")
    ;;
    (police             . "\x06\x05\x04\x00\x00\x00\x00\x00")
    (luxafor_x1         . "\x06\x01\x01\x00\x00\x00\x00\x00")
    (random1_x1         . "\x06\x02\x01\x00\x00\x00\x00\x00")
    (random2_x1         . "\x06\x03\x01\x00\x00\x00\x00\x00")
    (random3_x1         . "\x06\x04\x01\x00\x00\x00\x00\x00")
    (random4_x1         . "\x06\x06\x01\x00\x00\x00\x00\x00")
    (random5_x1         . "\x06\x07\x01\x00\x00\x00\x00\x00")
    ;;
    (red_flashes_x3     . "\x03\xff\xff\x00\x00\x0a\x00\x03")
    (green_flashes_x3   . "\x03\xff\x00\xff\x00\x0a\x00\x03")
    (blue_flashes_x3    . "\x03\xff\x00\x00\xff\x0a\x00\x03")
    (white_flashes_x3   . "\x03\xff\xff\xff\xff\x0a\x00\x03")
    (yellow_flashes_x3  . "\x03\xff\xff\xff\x00\x0a\x00\x03")
    (magenta_flashes_x3 . "\x03\xff\xff\x00\xff\x0a\x00\x03")
    (cyan_flashes_x3    . "\x03\xff\x00\xff\xff\x0a\x00\x03")
    ;;
    (sea_x5             . "\x04\x04\x00\x00\xff\x00\x05\x03")
    (white_wave_x5      . "\x04\x04\xff\xff\xff\x00\x05\x04")
    (synthetic_x5       . "\x04\x03\x00\xff\x00\x00\x05\x05"))
  "Known colours and patterns that can be written to the device.
It's an alist of pattern-name and associated raw binary value."
  :type '(alist)
  :tag "Luxafor Patterns"
  :group 'org-clocking-luxafor)

(defcustom org-clocking-luxafor-device-file
  "/dev/hidraw-luxafor"
  "Device file for the Luxafor device."
  :type '(file)
  :tag "Device file"
  :group 'org-clocking-luxafor)

(defun org-clocking-luxafor-patterns-names (patterns)
  "Get pattern names from PATTERNS alist."
  (cl-loop for (key . value) in org-clocking-luxafor-patterns
  			  collect (list 'const key)))

(defcustom org-clocking-luxafor-clock-in-pattern
  'red
  "Luxafor pattern to use for 'org-mode' clock-in."
  :type (append '(choice) (org-clocking-luxafor-patterns-names org-clocking-luxafor-patterns))
  :tag "Clock in pattern"
  :group 'org-clocking-luxafor)

(defcustom org-clocking-luxafor-clock-out-pattern
  'green
  "Luxafor pattern to use for 'org-mode' clock-out."
  :type (append '(choice) (org-clocking-luxafor-patterns-names org-clocking-luxafor-patterns))
  :tag "Clock out pattern"
  :group 'org-clocking-luxafor)

(defun org-clocking-luxafor-change-pattern (pattern)
  "Write the PATTERN associated raw byte string to the Luxafor device."
  (let ((coding-system-for-write 'binary)  ;; Tell emacs to write raw binary content
	(pattern-string (alist-get pattern org-clocking-luxafor-patterns)))
    (when pattern-string
      (with-temp-file org-clocking-luxafor-device-file
	(insert pattern-string)))))

(defun org-clocking-luxafor-clock-in ()
  "Function to be called from 'org-mode' clock-in hook to change Luxafor LEDs."
  (org-clocking-luxafor-change-pattern org-clocking-luxafor-clock-in-pattern)
  ;; Return true, so the hook doesnt think we finished in error
  t)

(defun org-clocking-luxafor-clock-out ()
  "Function to be called from 'org-mode' clock-out hook to change Luxafor LEDs."
  (org-clocking-luxafor-change-pattern org-clocking-luxafor-clock-out-pattern)
  ;; Return true, so the hook doesnt think we finished in error
  t)

(provide 'org-clocking-luxafor)

;;; org-clocking-luxafor.el ends here

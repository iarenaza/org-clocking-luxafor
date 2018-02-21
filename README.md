This package provides functions to change the colour of Luxafor
LEDs.  The functions are supposed to be called from 'org-mode'
clock-in and clock-out hooks.

To use the package, require it first:

    (require 'org-clocking-luxafor)

Or if you didn't install it in the load path, specify the path
to the elisp file. E.g:

    (require 'org-clocking-luxafor "~/lisp-code/org-clocking-luxafor.el")

Them simply hook the clock-in and clock-out functions to the
'org-mode' clock-in and clock-out hooks:

    (add-hook 'org-clock-in-hook #'org-clocking-luxafor-clock-in)
    (add-hook 'org-clock-out-hook #'org-clocking-luxafor-clock-out)

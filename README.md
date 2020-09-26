This package provides functions to change the colour of Luxafor
LEDs.  The functions are supposed to be called from 'org-mode'
clock-in and clock-out hooks.

Version 0.1 requires Emacs 23.0 or later and org-mode 8.0 or
later. Version 0.2 requires Emacs 24.3 or later and org-mode 8.0 or
later.

To use the package, require it first:

    (require 'org-clocking-luxafor)

Or if you didn't install it in the load path, specify the path
to the elisp file. E.g:

    (require 'org-clocking-luxafor "~/lisp-code/org-clocking-luxafor.el")

Then simply hook the `org-clocking-luxafor-clock-in` and
`org-clocking-luxafor-clock-out` functions to the 'org-mode' clock-in
and clock-out hooks:

    (add-hook 'org-clock-in-hook #'org-clocking-luxafor-clock-in)
    (add-hook 'org-clock-out-hook #'org-clocking-luxafor-clock-out)

From version 0.2 onwards, you can customize the Luxafor LED patterns
you want to use by using standard Emacs customization system. All the
configurable settings are available in the `org-clock-luxafor`
customization group.

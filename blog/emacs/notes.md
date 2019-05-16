# Learning Emacs again

Imagine you wake up in a world where Microsoft has acquired Github. That would
mean your choice do not want to go to Eclipse or Jetbrains and you sort of struggling with

## Starting over

The Meta Key is actually Esc-
C- Control+
M- Esc+

## Add an init.el file and install packages

Create a file `init.el` in the $HOME/.emacs.d directory with the following content:

```text
(require 'package)
(add-to-list 'package-archives (cons "melpa" "https://melpa.org/packages/") t)
```

M-x package-refresh-contents
C-s yaml-mode
Enter
i
x

## Navigate in the file

M->
M-<
Page-Up/Page-Down Fn+Arrow-Up Fn+ Arrow-Down

C- Control+
M- Esc+

C-x C-c: Quit the terminal

Select first Character: C-@
Navigate to the end of your selection
M-w to add the selection to the clipboard
C-y to yank the line
C-k to kill a line

Undo: C-u C-z z z z

C-x C-f: Open a file
C-x C-s: Save a file
C-x C-c: Quit the terminal

C-k to remove a line

Extensions

M-x list-packages



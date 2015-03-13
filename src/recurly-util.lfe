(defmodule recurly-util
  (export all))

(defun get-version ()
  (lutil:get-app-version 'recurly))

(defun get-versions ()
  (++ (lutil:get-versions)
      `(#(recurly ,(get-version)))))

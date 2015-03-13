(defmodule rcrly-util
  (export all))

(defun get-version ()
  (lutil:get-app-version 'rcrly))

(defun get-versions ()
  (++ (lutil:get-versions)
      `(#(rcrly ,(get-version)))))

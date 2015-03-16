(defmodule rcrly-util
  (export all))

(defun get-version ()
  (lutil:get-app-version 'rcrly))

(defun get-versions ()
  (++ (lutil:get-versions)
      `(#(rcrly ,(get-version)))))

(defun arg->str
  ((arg) (when (is_integer arg))
   (arg->str (integer_to_list arg)))
  ((arg) (when (is_atom arg))
   (arg->str (atom_to_list arg)))
  ((arg) arg))
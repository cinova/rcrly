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

(defun ->atom
  ((x) (when (is_list x))
   (list_to_atom x))
  ((x) (when (is_integer x))
   (list_to_atom (integer_to_list x)))
  ((x) x))

(defun get-defined
  ;; undefined OS env values will match false
  (((cons 'false rest))
   (get-defined rest))
  ;; undefined INI values will match undefined
  (((cons 'undefined rest))
   (get-defined rest))
  (((cons match _))
   match))

(defun ->int
  ((str) (when (is_list str))
   (list_to_integer str))
  ((x)
   x))
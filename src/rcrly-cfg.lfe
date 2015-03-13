;;;; Provide simple wrappers around the various ways in which one can obtain
;;;; configuration data.
;;;;
;;;; The code below assumes the following order of lookup:
;;;;  * First look in the system ENV
;;;;  * Then a standard config file
;;;;  * Failing that, use the value defined in this module
;;;;
(defmodule rcrly-cfg
  (export all))

;;; Default configuration values, used as a last resort
(defun host () "cinova.recurly.com")
(defun key () "")
(defun default-currency () "USD")

(defun get (key)
  "The wrapper for getting config info."
  'noop)

(defun get-key ()
  'noop)

(defun get-host ()
  'noop)

(defun get-default-currench ()
  'noop)
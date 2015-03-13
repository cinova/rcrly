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
(defun api-key () "")
(defun remote-api-version () "v2")
(defun default-currency () "USD")
(defun request-timeout () (* 30 1000)) ; in milliseconds

(defun get (key)
  "The wrapper for getting config info."
  ;; XXX add more here later
  (os:getenv key))

(defun get (key default)
  (let ((value (get key)))
    (if (=:= value 'false)
      default
      value)))

(defun get-api-key ()
  (get "RECURLY_API_KEY"
       (api-key)))

(defun get-host ()
  (get "RECURLY_HOST"
       (host)))

(defun get-default-currency ()
  (get "RECURLY_DEFAULT_CURRENCY"
       (default-currency)))

(defun get-remote-api-version ()
  (get "RECURLY_VERSION"
       (remote-api-version)))

(defun get-request-timeout ()
  (get "RECURLY_REQUEST_TIMEOUT"
       (request-timeout)))
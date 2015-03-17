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

(defun host () "yourname.recurly.com")
(defun api-key () "GFEDCBA9876543210")
(defun remote-api-version () "v2")
(defun default-currency () "USD")
(defun request-timeout () (* 30 1000)) ; in milliseconds
(defun config-file () "~/.rcrly/lfe.ini")
(defun config-id () 'rcrly-ini)
(defun config-section () "REST API")

;;; General config functions

(defun get-api-key ()
  (rcrly-util:get-defined
    (list (os:getenv "RECURLY_API_KEY")
          (get-ini-value 'api)
          (api-key))))

(defun get-host ()
  (rcrly-util:get-defined
    (list (os:getenv "RECURLY_HOST")
          (get-ini-value 'host)
          (host))))

(defun get-default-currency ()
  (rcrly-util:get-defined
    (list (os:getenv "RECURLY_DEFAULT_CURRENCY")
          (get-ini-value 'default-currency)
          (default-currency))))

(defun get-remote-api-version ()
  (rcrly-util:get-defined
    (list (os:getenv "RECURLY_VERSION")
          (get-ini-value 'version)
          (remote-api-version))))

(defun get-request-timeout ()
  (rcrly-util:get-defined
    (list (rcrly-util:->int (os:getenv "RECURLY_REQUEST_TIMEOUT"))
          (rcrly-util:->int (get-ini-value 'timeout))
          (request-timeout))))

;;; Config INI

(defun open-cfg-file ()
  (open-cfg-file (config-file)))

(defun open-cfg-file (filename)
  (econfig:register_config
    (config-id)
    (list (lutil-file:expand-home-dir filename))
    (list 'autoreload)))

(defun get-ini-value (key)
  (get-ini-value (config-section) key))

(defun get-ini-value (section key)
  (econfig:get_value (config-id) section key))

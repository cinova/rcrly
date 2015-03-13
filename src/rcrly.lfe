(defmodule rcrly
  (export all))

(include-lib "rcrly/include/options.lfe")

(defun get-default-options ()
  (make-conn host (rcrly-cfg:get-host)
             key (rcrly-cfg:get-key)
             default-currency (rcrly-cfg:get-default-currency)))

(defun new ()
  (new (get-default-options)))

(defun new (connection-options)
  connection-options)
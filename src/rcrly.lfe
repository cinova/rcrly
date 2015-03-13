(defmodule rcrly
  (export all))

(include-lib "rcrly/include/options.lfe")

(defun start ()
  `(#(inets ,(inets:start))
    #(ssl ,(ssl:start))
    #(lhttpc ,(lhttpc:start))))

(defun new ()
  (new (get-default-options)))

(defun new (connection-options)
  connection-options)

(defun get (endpoint)
  (rcrly-httpc:request endpoint "GET" ""))

(defun post (endpoint data)
  (rcrly-httpc:request endpoint "POST" data))

(defun get-default-options ()
  (make-conn host (rcrly-cfg:get-host)
             key (rcrly-cfg:get-api-key)
             default-currency (rcrly-cfg:get-default-currency)))
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

;;; Convenience client functions

(defun get (endpoint)
  (get endpoint '()))

(defun get (endpoint client-options)
  (rcrly-httpc:request
    endpoint
    "GET"
    ""
    client-options))

(defun post (endpoint data)
  (post endpoint data '()))

(defun post (endpoint data client-options)
  (rcrly-httpc:request
    endpoint
    "POST"
    data
    client-options))

;;; API functions

(defun get-accounts ()
  (get "/accounts"))

(defun get-accounts (client-options)
  (get "/accounts" client-options))

(defun get-account (id)
  (get (++ "/accounts/"
           (rcrly-util:arg->str id))))

;;; Utility functions for this module

(defun get-default-options ()
  (make-conn host (rcrly-cfg:get-host)
             key (rcrly-cfg:get-api-key)
             default-currency (rcrly-cfg:get-default-currency)))
(defmodule rcrly
  (export all))

(include-lib "rcrly/include/options.lfe")

(defun start ()
  (prog1
    `(#(logjam ,(logjam:setup))
      #(gproc ,(application:start 'gproc))
      #(econfig ,(application:start 'econfig))
      #(inets ,(inets:start))
      #(ssl ,(ssl:start))
      #(lhttpc ,(lhttpc:start)))
    (rcrly-cfg:open-cfg-file)))

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

(defun put (endpoint data)
  (post endpoint data '()))

(defun put (endpoint data client-options)
  (rcrly-httpc:request
    endpoint
    "PUT"
    data
    client-options))

(defun post (endpoint data)
  (post endpoint data '()))

(defun post (endpoint data client-options)
  (rcrly-httpc:request
    endpoint
    "POST"
    data
    client-options))

(defun delete (endpoint)
  (delete endpoint '()))

(defun delete (endpoint client-options)
  (rcrly-httpc:request
    endpoint
    "DELETE"
    ""
    client-options))

;;; API functions

;;; Account API

(defun get-accounts ()
  (get-accounts '()))

(defun get-accounts (client-options)
  (get "/accounts" client-options))

(defun get-account (id)
  (get-account id '()))

(defun get-account (id client-options)
  (get (++ "/accounts/"
           (rcrly-util:arg->str id))
       client-options))

;;; Adjustment API

(defun get-adjustments (account-id)
  (get-adjustments account-id '()))

(defun get-adjustments (account-id client-options)
  (get (++ "/accounts/"
           (rcrly-util:arg->str account-id)
           "/adjustments")
       client-options))

(defun get-adjustment (uuid)
  (get-adjustment uuid '()))

(defun get-adjustment (uuid client-options)
  (get (++ "/adjustments/"
           (rcrly-util:arg->str uuid))
       client-options))

;;; Billing API

(defun get-billing-info (account-id)
  (get-billing-info account-id '()))

(defun get-billing-info (account-id client-options)
  (get (++ "/accounts/"
           (rcrly-util:arg->str account-id)
           "/billing_info")
       client-options))

(defun update-billing-info (account-id data)
  (update-billing-info account-id data '()))

(defun update-billing-info (account-id data client-options)
  (put (++ "/accounts/"
           (rcrly-util:arg->str account-id)
           "/billing_info")
       data
       client-options))

;;; Invoice API

(defun get-all-invoices ()
  (get-all-invoices '()))

(defun get-all-invoices (client-options)
  (get "/invoices" client-options))

(defun get-invoices (account-id)
  (get-invoices account-id '()))

(defun get-invoices (account-id client-options)
  (get (++ "/accounts/"
           (rcrly-util:arg->str account-id)
           "/invoices")
       client-options))

;;; Plan API

(defun create-plan (data)
  (create-plan data '()))

(defun create-plan (data client-options)
  (post "/plans" data client-options))

(defun delete-plan (plan-code)
  (delete-plan plan-code '()))

(defun delete-plan (plan-code client-options)
  (delete (++ "/plans/"
              (rcrly-util:arg->str plan-code))
          client-options))

;;; Transaction API

(defun get-all-transactions ()
  (get-all-transactions '()))

(defun get-all-transactions (client-options)
  (get "/transactions" client-options))

(defun get-transactions (account-id)
  (get-transactions account-id '()))

(defun get-transactions (account-id client-options)
  (get (++ "/accounts/"
           (rcrly-util:arg->str account-id)
           "/transactions")
       client-options))

;;; Utility functions for this module

(defun get-default-options ()
  (make-conn host (rcrly-cfg:get-host)
             key (rcrly-cfg:get-api-key)
             default-currency (rcrly-cfg:get-default-currency)))

(defun get-data (results)
  (rcrly-xml:get-data results))

(defun get-in (keys results)
  (rcrly-xml:get-in keys results))

(defun get-linked (keys results)
  (rcrly-xml:get-linked keys results))
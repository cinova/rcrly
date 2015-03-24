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

(defun get-account (account-id)
  (get-account account-id '()))

(defun get-account (account-id client-options)
  (get (++ "/accounts/"
           (rcrly-util:arg->str account-id))
       client-options))

(defun create-account(data)
  (create-account data '()))

(defun create-account (data client-options)
  (post "/accounts" data client-options))

(defun update-account (account-id data)
  (update-account account-id data '()))

(defun update-account (account-id data client-options)
  (put (++ "/accounts/"
           (rcrly-util:arg->str account-id))
       data
       client-options))

(defun close-account (account-id)
  (close-account account-id '()))

(defun close-account (account-id client-options)
  (delete (++ "/accounts/"
              (rcrly-util:arg->str account-id))
          client-options))

(defun reopen-account (account-id)
  (reopen-account account-id '()))

(defun reopen-account (account-id client-options)
  (put (++ "/accounts/"
           (rcrly-util:arg->str account-id)
           "/reopen")
       ""
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

(defun get-invoice (invoice-id)
  (get-invoice invoice-id '()))

(defun get-invoice (invoice-id client-options)
  (get (++ "/invoices/"
           (rcrly-util:arg->str invoice-id))
       client-options))

;;; Plan API

(defun get-plans ()
  (get-plans '()))

(defun get-plans (client-options)
  (get "/plans" client-options))

(defun get-plan (plan-id)
  (get-plan plan-id '()))

(defun get-plan (plan-id client-options)
  (get (++ "/plans/"
           (rcrly-util:arg->str plan-id))
       client-options))

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

;;; Subscription API

(defun get-all-subscriptions ()
  (get-all-subscriptions '()))

(defun get-all-subscriptions (client-options)
  (get "/subscriptions" client-options))

(defun get-subscriptions (account-id)
  (get-subscriptions account-id '()))

(defun get-subscriptions (account-id client-options)
  (get (++ "/accounts/"
           (rcrly-util:arg->str account-id)
           "/subscriptions")
       client-options))

(defun get-subscription (subscription-uuid)
  (get-subscription subscription-uuid '()))

(defun get-subscription (subscription-uuid client-options)
  (get (++ "/subscriptions/"
           subscription-uuid)
       client-options))

(defun create-subscription (data)
  (create-subscription data '()))

(defun create-subscription (data client-options)
  (post "/subscriptions" data client-options))

(defun update-subscription (subscription-uuid data)
  (update-subscription subscription-uuid data '()))

(defun update-subscription (subscription-uuid data client-options)
  (put (++ "/subscriptions/"
           subscription-uuid)
       data
       client-options))

(defun terminate-subscription (subscription-uuid)
  (terminate-subscription subscription-uuid '()))

(defun terminate-subscription (subscription-uuid client-options)
  (put (++ "/subscriptions/"
           subscription-uuid
           "/terminate"
           ;; XXX add options for termination type
           ;; See related issue: https://github.com/cinova/rcrly/issues/3
           )
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
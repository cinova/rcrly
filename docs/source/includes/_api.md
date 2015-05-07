# The API

Each API call has a default arity and then an arity+1 where the "+1" is an
argument for rcrly client options (see the "Options" section above).

For each of the API functions listed below, be sure to examine the linked
Recurly documentation for information about payloads.

## Accounts

Recurly [Accounts documentation](https://docs.recurly.com/api/accounts)

### ``get-accounts``

Get all accounts.

```lisp
> (set `#(ok ,accounts) (rcrly:get-accounts))
#(ok
  (#(account ...)
   #(account ...)))
> (length accounts)
2
```

### ``get-account``

Takes a single arguement and returns data for the account associated with
the provided id.

```lisp
> (set `#(ok ,account) (rcrly:get-account 1))
#(ok
  #(account
    (#(adjustments ...)
     ...)))
> (rcrly:get-in '(account state) account)
"active"
> (rcrly:get-in '(account address city) account)
"Fairville"
```

### ``create-account``

Takes payload data.

To use from the REPL, first, pull in the XML macros:

```lisp
> (slurp "src/rcrly-xml.lfe")
#(ok rcrly-xml)
```

Now create your payload:

```lisp
> (set payload
    (xml/account
      (list
        (xml/account_code "123")
        (xml/email "alice@example.com")
        (xml/first_name "Alice")
        (xml/last_name "Guthrie"))))
"<account>...</account>"
```

Now make the API call to create the account:

```lisp
> (set `#(ok ,account) (rcrly:create-account payload))
#(ok
  #(account ...))
```

With the planaccount created, we can extract data from the results:

```lisp
> (rcrly:get-in '(account email) account)
"alice@example.com"
```

### ``update-account``

Takes account id and payload data.

To use from the REPL, first, pull in the XML macros:

```lisp
> (slurp "src/rcrly-xml.lfe")
#(ok rcrly-xml)
```

Now create your payload:

```lisp
> (set payload
    (xml/account
        (xml/company_name "Alice's Hacker Cafe")))
"<account>...</account>"
```

Now make the API call to create the account:

```lisp
> (set `#(ok ,account) (rcrly:update-account 123 payload))
#(ok
  #(account ...))
```

With the planaccount created, we can extract data from the results:

```lisp
> (rcrly:get-in '(account email) account)
"alice@example.com"
> (rcrly:get-in '(account company_name) account)
"Alice's Hacker Cafe"
```

### ``close-account``

Takes an account id.

```lisp
> (set `#(ok "") (rcrly:close-account 123))
#(ok ())
```

### ``reopen-account``

Takes an account id.

```lisp
> (set `#(ok ,account) (rcrly:reopen-account 123))
#(ok
  #(account ...))
```

## Adjustments

Recurly [Adjustments documentation](https://docs.recurly.com/api/adjustments)

### ``get-adjustments``

Takes an account id.

```lisp
> (set `#(ok ,adjustments) (rcrly:get-adjustments 1))
#(ok
  #(adjustments
    (#(type "array"))
    (#(adjustment ...)
     #(adjustment ...)
     ...)))
```

### ``get-adjustment``

Takes a UUID.

```lisp
> (set `#(ok ,adjustment) (rcrly:get-adjustment "2d97cfa52e80a675a532ba4e8ea25401"))
#(ok
  #(adjustment
    (#(type "credit")
     #(href
       "https://yourname.recurly.com/v2/adjustments/2d97cf12a5...."))
    (#(account (#(href "https://yourname.recurly.com/v2/accounts/1")) ())
     #(uuid () ("2d97cfa52e80a675a532ba4e8ea25401"))
     #(state () ("pending"))
     ...
     #(origin () ("credit"))
     ...
     #(total_in_cents (#(type "integer")) ("-100"))
     #(currency () ("USD"))
     #(taxable (#(type "boolean")) ("false"))
     #(start_date (#(type "datetime")) ("2015-03-17T18:34:56Z"))
     #(end_date (#(nil "nil")) ())
     #(created_at (#(type "datetime")) ("2015-03-17T18:34:56Z")))))
```
```lisp
> (rcrly:get-in '(adjustment total_in_cents) adjustment)
"-100"
> (rcrly:get-in '(adjustment state) adjustment)
"pending"
> (rcrly:get-in '(adjustment origin) adjustment)
"credit"
```

## Billing Info

Recurly [Billing Info documentation](https://docs.recurly.com/api/billing-info)

### ``get-billing-info``

Takes an account id.

```lisp
> (set `#(ok ,info) (rcrly:get-billing-info 1))
#(ok
  #(billing_info
    (#(type "credit_card")
     #(href "https://yourname.recurly.com/v2/accounts/1/billing_info"))
    (#(account (#(href "https://yourname.recurly.com/v2/accounts/1")) ())
     ...
     #(company (#(nil "nil")) ())
     #(address1 () ("108 Main St"))
     ...
     #(city () ("Fairville"))
     #(state () ("WI"))
     #(zip () ("12345"))
     ...
     #(card_type () ("Visa"))
     #(year (#(type "integer")) ("2016"))
     #(month (#(type "integer")) ("3"))
     ...)))
```
```lisp
> (rcrly:get-in '(billing_info card_type) info)
"Visa"
```

### ``update-billing-info``

Takes payload data.

To use from the REPL, first pull in the XML macros:

```lisp
> (slurp "src/rcrly-xml.lfe")
#(ok rcrly-xml)
```

Now set some argument values (simply done here to keep things more readable):

```lisp
> (set account-id 1)
1
> (set payload
    (xml/billing_info
        (list (xml/first_name "Verena")
              (xml/last_name "Example"))))
"<billing_info> ... </billing_info>"
```

And with those in place, you can made your API call to update the billing
info:

```lisp
> (set `#(ok ,info) (rcrly:update-billing-info account-id payload))
#(ok
  #(billing_info
    (#(type "credit_card")
     #(href "https://yourname.recurly.com/v2/accounts/1/billing_info"))
    (#(account (#(href "https://yourname.recurly.com/v2/accounts/1")) ())
     ...
     #(company (#(nil "nil")) ())
     #(address1 () ("108 Main St"))
     ...
     #(city () ("Fairville"))
     #(state () ("WI"))
     #(zip () ("12345"))
     ...
     #(card_type () ("Visa"))
     #(year (#(type "integer")) ("2016"))
     #(month (#(type "integer")) ("3"))
     ...)))
```

And we can easily confirm that our results have the updated data:

```lisp
> (rcrly:get-in '(billing_info first_name) info)
"Verena"
```

### ``clear-billing-info``

## Invoices

Recurly [Invoices documentation](https://docs.recurly.com/api/invoices)

### ``get-all-invoices``

Takes no arguments:

```lisp
> (set `#(ok ,invoices) (rcrly:get-all-invoices))
#(ok
  #(invoices ...))
```

### ``get-invoices``

Takes an account id:

```lisp
> (set `#(ok ,invoices) (rcrly:get-invoices 123))
#(ok
  #(invoices ...))
```

### ``get-invoice``

Takes an invoice number:

```lisp
> (set `#(ok ,invoice) (rcrly:get-invoice 1402))
#(ok
  #(invoice ...))
```

### ``get-invoice-pdf``

### ``preview-invoice``

### ``invoice``

### ``set-paid-invoice``

### ``set-failed-invoice``

### ``set-line-refund-invoice``

### ``set-open-refund-invoice``

## Plans

Recurly [Invoices documentation](https://docs.recurly.com/api/plans)

### ``get-plans``

Takes no arguments:

```lisp
> (set `#(ok ,plans) (rcrly:get-plans))
#(ok
  #(plans
    (#(type "array"))
    (#(plan ...))))
```

### ``get-plan``

Takes a plan code:

```lisp
> (set `#(ok ,plan) (rcrly:get-plan 1402))
#(ok
  #(plan ...))
```

```lisp
> (rcrly:get-in '(plan name) plan)
"30-Day Free Trial"
```

### ``create-plan``

Takes payload data.

To use from the REPL, first, pull in the XML macros:

```lisp
> (slurp "src/rcrly-xml.lfe")
#(ok rcrly-xml)
```

Now create your payload:

```lisp
> (set payload
    (xml/plan
      (list
        (xml/plan_code "gold")
        (xml/name "Gold plan")
        (xml/setup_fee_in_cents
          (list
            (xml/USD "1000")
            (xml/EUR "800")))
        (xml/unit_amount_in_cents
          (list
            (xml/USD "6000")
            (xml/EUR "4500")))
        (xml/plan_interval_length "1")
        (xml/plan_interval_unit "months")
        (xml/tax_exempt "false"))))
"<plan>...</plan>"
```

Now make the API call to create the plan:

```lisp
> (set `#(ok ,plan) (rcrly:create-plan payload))
#(ok
  #(plan ...))
```

With the plan created, we can extract data from the results:

```lisp
> (rcrly:get-in '(plan setup_fee_in_cents EUR) plan)
"4500"
```

### ``update-plan``

### ``delete-plan``

To delete a plan, simply pass the plan code to ``delete-plan``:

```lisp
> (set `#(ok ,results) (rcrly:delete-plan "gold"))
[response TBD]
```

## Subscriptions

### ``get-all-subscriptions``

Takes no arguments.

```lisp
> (set `#(ok ,subs) (rcrly:get-all-subscriptions '()))
#(ok
  #(subscriptions
    (#(type "array"))
    (#(subscription ...))))
```

### ``get-subscriptions``

Takes an account id:

```lisp
> (set `#(ok ,subs) (rcrly:get-subscriptions 123))
#(ok
  #(subscriptions
    (#(type "array"))
    (#(subscription ...))))
```

### ``get-subscription``

Takes a subscription UUID:

```lisp
> (set uuid "2dbc6c2cb823174353853a409c90d419")
"2dbc6c2cb823174353853a409c90d419"
> (set `#(ok ,subs) (rcrly:get-subscription uuid))
#(ok
  #(subscription ...))
```

Extract data as needed:


```lisp
> (rcrly:get-in '(subscription current_period_started_at) subs)
"2015-03-24T21:12:14Z"
```

### ``create-subscription``

Takes payload data.

To use from the REPL, first, pull in the XML macros:

```lisp
> (slurp "src/rcrly-xml.lfe")
#(ok rcrly-xml)
```

Now create your payload:

```lisp
> (set payload
    (xml/subscription
      (list
        (xml/plan_code "gold")
        (xml/currency "USD")
        (xml/account
          (xml/account_code "123")))))
"<subscription>...</subscription>"
```

Now make the API call to create the plan:

```lisp
> (set `#(ok ,subs) (rcrly:create-subscription payload))
#(ok
  #(subscription ...))
```

With the plan created, we can extract data from the results:

```lisp
> (rcrly:get-in '(subscription plan name) subs)
"Gold plan"
```

### ``preview-subscription``

### ``update-subscription``

Takes subscription UUID and payload data.

To use from the REPL, first, pull in the XML macros:

```lisp
> (slurp "src/rcrly-xml.lfe")
#(ok rcrly-xml)
```

Now create your payload:

```lisp
> (set uuid "2dbc6c2cb823174353853a409c90d419")
"2dbc6c2cb823174353853a409c90d419"
> (set payload
    (xml/subscription
      (list
        (xml/timeframe "now")
        (xml/plan_code "silver"))))
"<subscription>...</subscription>"
```

Now make the API call to create the plan:

```lisp
> (set `#(ok ,subs) (rcrly:update-subscription uuid payload))
#(ok
  #(subscription ...))
```

With the plan created, we can extract data from the results:

```lisp
> (rcrly:get-in '(subscription plan name) subs)
"Silver plan"
```

### ``update-subscription-notes``

### ``cancel-subscription``

Takes a subscription UUID:

```lisp
> (set uuid "2dbc6c2cb823174353853a409c90d419")
"2dbc6c2cb823174353853a409c90d419"
> (set #(ok ,subs) (rcrly:cancel-subscription uuid))
#(ok
  #(subscription ...))
```

And you can check the subscription state:

```lisp
> (rcrly:get-in '(subscription state) subs)
"canceled"
```

### ``reactivate-subscription``

Takes a subscription UUID:

```lisp
> (set uuid "2dbc6c2cb823174353853a409c90d419")
"2dbc6c2cb823174353853a409c90d419"
> (set #(ok ,subs) (rcrly:reactivate-subscription uuid))
#(ok
  #(subscription ...))
```

Check the subscription state:

```lisp
> (rcrly:get-in '(subscription state) subs)
"active"
```

### ``terminate-subscription``

Takes a subscription UUID:

```lisp
> (set uuid "2dbc6c2cb823174353853a409c90d419")
"2dbc6c2cb823174353853a409c90d419"
> (set #(ok ,subs) (rcrly:terminate-subscription uuid))
#(ok
  #(subscription ...))
```

Check the subscription state:

```lisp
> (rcrly:get-in '(subscription statue) subs)
"expired"
```

### ``postpone-subscription``

## Transactions

Recurly [Transactions documentation](https://docs.recurly.com/api/transactions)

### ``get-all-transactions``

### ``get-transactions``

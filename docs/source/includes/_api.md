# The API

Each API call has a default arity and then an arity+1 where the "+1" is an
argument for rcrly client options (see the "Options" section above).

For each of the API functions listed below, be sure to examine the linked
Recurly documentation for information about payloads.

## Accounts

Recurly [Accounts documentation](https://docs.recurly.com/api/accounts)

### ``get-accounts``

> Get all accounts:

```cl
> (set `#(ok ,accounts) (rcrly:get-accounts))
```

> Results:

```cl
#(ok
  (#(account ...)
   #(account ...)))
> (length accounts)
2
```

Pages on all accounts in the system.


### ``get-account``

> Takes a single arguement and returns data for the account associated with
the provided id:

```cl
> (set `#(ok ,account) (rcrly:get-account 1))
```

> Results:

```cl
#(ok
  #(account
    (#(adjustments ...)
     ...)))
> (rcrly:get-in '(account state) account)
"active"
> (rcrly:get-in '(account address city) account)
"Fairville"
```

Get a particular account by account ID.

### ``create-account``

> To use from the REPL, first, pull in the XML macros:

```cl
> (slurp "src/rcrly-xml.lfe")
#(ok rcrly-xml)
```

> Now create your payload:

```cl
> (set payload
    (xml/account
      (list
        (xml/account_code "123")
        (xml/email "alice@example.com")
        (xml/first_name "Alice")
        (xml/last_name "Guthrie"))))
```

> Which will give you:

```xml
"<account>...</account>"
```

> Now make the API call to create the account:

```cl
> (set `#(ok ,account) (rcrly:create-account payload))
#(ok
  #(account ...))
```

> With the account created, we can extract data from the results:

```cl
> (rcrly:get-in '(account email) account)
"alice@example.com"
```

Create an account based upon provided payload data.


### ``update-account``

> Create your payload:

```cl
> (set payload
    (xml/account
        (xml/company_name "Alice's Hacker Cafe")))
"<account>...</account>"
```

> Now make the API call to update the account:

```cl
> (set `#(ok ,account) (rcrly:update-account 123 payload))
#(ok
  #(account ...))
```

> With the account updated, we can extract data from the results:

```cl
> (rcrly:get-in '(account email) account)
"alice@example.com"
> (rcrly:get-in '(account company_name) account)
"Alice's Hacker Cafe"
```

This function takes account id and payload data.


### ``close-account``

> Close an account:


```cl
> (set `#(ok "") (rcrly:close-account 123))
#(ok ())
```

Takes an account id.


### ``reopen-account``


> Re-open an account that had been closed:

```cl
> (set `#(ok ,account) (rcrly:reopen-account 123))
#(ok
  #(account ...))
  ```
  
Takes an account id.


## Adjustments

Recurly [Adjustments documentation](https://docs.recurly.com/api/adjustments)

### ``get-adjustments``

> Get all adjustments:

```cl
> (set `#(ok ,adjustments) (rcrly:get-adjustments 1))
```

> Results:

```cl
#(ok
  #(adjustments
    (#(type "array"))
    (#(adjustment ...)
     #(adjustment ...)
     ...)))
```

Takes an account id.

### ``get-adjustment``

> Get a particular adjustment:

```cl
> (set `#(ok ,adjustment) (rcrly:get-adjustment "2d97cfa52e80a675a532ba4e8ea25401"))
```

> Results:

```cl
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

> Now you can do the usual things:

```cl
> (rcrly:get-in '(adjustment total_in_cents) adjustment)
"-100"
> (rcrly:get-in '(adjustment state) adjustment)
"pending"
> (rcrly:get-in '(adjustment origin) adjustment)
"credit"
```

Takes a UUID.

## Billing Info

Recurly [Billing Info documentation](https://docs.recurly.com/api/billing-info)

### ``get-billing-info``

> Get billing info for a particular account:

```cl
> (set `#(ok ,info) (rcrly:get-billing-info 1))
```

> Results:

```cl
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

> Extract some data:

```cl
> (rcrly:get-in '(billing_info card_type) info)
"Visa"
```

Takes an account id.

### ``update-billing-info``


To update billing info from the REPL, first pull in the XML macros:

```cl
> (slurp "src/rcrly-xml.lfe")
#(ok rcrly-xml)
```

> Now set some argument values (helps to keep things more readable):

```cl
> (set account-id 1)
1
> (set payload
    (xml/billing_info
        (list (xml/first_name "Verena")
              (xml/last_name "Example"))))
"<billing_info> ... </billing_info>"
```

> With those in place, you can made your API call to update the billing
info:

```cl
> (set `#(ok ,info) (rcrly:update-billing-info account-id payload))
```

> Results:

```cl
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

> We can easily confirm that our results have the updated data:

```cl
> (rcrly:get-in '(billing_info first_name) info)
"Verena"
```

Takes payload data.

### ``clear-billing-info``

TBD


## Invoices

Recurly [Invoices documentation](https://docs.recurly.com/api/invoices)

### ``get-all-invoices``

> Get all the invoices for all accounts:

```cl
> (set `#(ok ,invoices) (rcrly:get-all-invoices))
#(ok
  #(invoices ...))
```

Takes no arguments.


### ``get-invoices``

> Get all the invoices for one account:

```cl
> (set `#(ok ,invoices) (rcrly:get-invoices 123))
```

> Results:

```cl
#(ok
  #(invoices ...))
```

Takes an account id.


### ``get-invoice``

> Get a particular invoice:

```cl
> (set `#(ok ,invoice) (rcrly:get-invoice 1402))
```

Result has the follwoing form:

```cl
#(ok
  #(invoice ...))
```

Takes an invoice number:

### ``get-invoice-pdf``

TBD

### ``preview-invoice``

TBD

### ``invoice``

TBD

### ``set-paid-invoice``

TBD

### ``set-failed-invoice``

TBD

### ``set-line-refund-invoice``

TBD

### ``set-open-refund-invoice``

TBD


## Plans

Recurly [Invoices documentation](https://docs.recurly.com/api/plans)

### ``get-plans``

> Get all plans:

```cl
> (set `#(ok ,plans) (rcrly:get-plans))
```

> Results:

```cl
#(ok
  #(plans
    (#(type "array"))
    (#(plan ...))))
```

Takes no arguments.


### ``get-plan``

> Get a specific plan:

```cl
> (set `#(ok ,plan) (rcrly:get-plan 1402))
#(ok
  #(plan ...))
```

> Extract the plan name:

```cl
> (rcrly:get-in '(plan name) plan)
"30-Day Free Trial"
```

Takes a plan code.

### ``create-plan``


> Create your payload:

```cl
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
```
```xml
"<plan>...</plan>"
```

> Now make the API call to create the plan:

```cl
> (set `#(ok ,plan) (rcrly:create-plan payload))
#(ok
  #(plan ...))
```

> With the plan created, we can extract data from the results:

```cl
> (rcrly:get-in '(plan setup_fee_in_cents EUR) plan)
"4500"
```

Takes payload data.


### ``update-plan``

TBD

### ``delete-plan``

> To delete a plan, simply pass the plan code to ``delete-plan``:

```cl
> (set `#(ok ,results) (rcrly:delete-plan "gold"))
[response TBD]
```

## Subscriptions

Recurly [InvoicesSubscriptions documentation](https://docs.recurly.com/api/subscriptions)

### ``get-all-subscriptions``

> Get all subscriptions:

```cl
> (set `#(ok ,subs) (rcrly:get-all-subscriptions '()))
#(ok
  #(subscriptions
    (#(type "array"))
    (#(subscription ...))))
```

Takes no arguments.

### ``get-subscriptions``

> Get all subscriptions for an account:

```cl
> (set `#(ok ,subs) (rcrly:get-subscriptions 123))
#(ok
  #(subscriptions
    (#(type "array"))
    (#(subscription ...))))
```

Takes an account id:


### ``get-subscription``

> Get a particular subscription:

```cl
> (set uuid "2dbc6c2cb823174353853a409c90d419")
"2dbc6c2cb823174353853a409c90d419"
> (set `#(ok ,subs) (rcrly:get-subscription uuid))
#(ok
  #(subscription ...))
```

> Extract data as needed:

```cl
> (rcrly:get-in '(subscription current_period_started_at) subs)
"2015-03-24T21:12:14Z"
```

Takes a subscription UUID:


### ``create-subscription``

> To create a subscription, first create your payload:

```cl
> (set payload
    (xml/subscription
      (list
        (xml/plan_code "gold")
        (xml/currency "USD")
        (xml/account
          (xml/account_code "123")))))
```
```xml
"<subscription>...</subscription>"
```

> Now make the API call to create the plan:

```cl
> (set `#(ok ,subs) (rcrly:create-subscription payload))
#(ok
  #(subscription ...))
```

> With the plan created, we can extract data from the results:

```cl
> (rcrly:get-in '(subscription plan name) subs)
"Gold plan"
```

Takes payload data.

### ``preview-subscription``

TBD

### ``update-subscription``

> To update a subscription, create your payload:

```cl
> (set uuid "2dbc6c2cb823174353853a409c90d419")
"2dbc6c2cb823174353853a409c90d419"
> (set payload
    (xml/subscription
      (list
        (xml/timeframe "now")
        (xml/plan_code "silver"))))
"<subscription>...</subscription>"
```

> Now make the API call to create the plan:

```cl
> (set `#(ok ,subs) (rcrly:update-subscription uuid payload))
#(ok
  #(subscription ...))
```

> With the plan created, we can extract data from the results:

```cl
> (rcrly:get-in '(subscription plan name) subs)
"Silver plan"
```

Takes subscription UUID and payload data.


### ``update-subscription-notes``

TBD

### ``cancel-subscription``

> To cancel a subscription:

```cl
> (set uuid "2dbc6c2cb823174353853a409c90d419")
"2dbc6c2cb823174353853a409c90d419"
> (set #(ok ,subs) (rcrly:cancel-subscription uuid))
#(ok
  #(subscription ...))
```

> And you can check the subscription state:

```cl
> (rcrly:get-in '(subscription state) subs)
"canceled"
```

Takes a subscription UUID.


### ``reactivate-subscription``

> To reactivate a subscription:

```cl
> (set uuid "2dbc6c2cb823174353853a409c90d419")
"2dbc6c2cb823174353853a409c90d419"
> (set #(ok ,subs) (rcrly:reactivate-subscription uuid))
#(ok
  #(subscription ...))
```

> Check the subscription state:

```cl
> (rcrly:get-in '(subscription state) subs)
"active"
```

Takes a subscription UUID

### ``terminate-subscription``

To terminate a subscription:

```cl
> (set uuid "2dbc6c2cb823174353853a409c90d419")
"2dbc6c2cb823174353853a409c90d419"
> (set #(ok ,subs) (rcrly:terminate-subscription uuid))
#(ok
  #(subscription ...))
```

> Check the subscription state:

```cl
> (rcrly:get-in '(subscription statue) subs)
"expired"
```

Takes a subscription UUID

### ``postpone-subscription``

## Transactions

Recurly [Transactions documentation](https://docs.recurly.com/api/transactions)

### ``get-all-transactions``

TBD

### ``get-transactions``

TBD

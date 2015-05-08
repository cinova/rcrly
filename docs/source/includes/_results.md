# Working with Results

> Example form for multi-valued results:

```cl
#(ok
  #(accounts
    (...) ; attributes
    (#(account
        (...) ; attributes
        (...) ; child elements
        )
     #(account ...)
     #(account ...)
     ...)))
```

> Example form for single-valued results:

```cl
#(ok
  #(account
    (...) ; attributes
    (...) ; child elements
    ))
```


All results in rcrly are of the form ``#(ok ...)`` or ``#(error ...)``, with the
elided contents of those tuples changing depending upon context. This is the
standard approach for Erlang libraries, so should be quite familiar to users.

Recurly's API is XML-based; the rcrly API inherits some of its characteristics
from this fact. In particular, data structures representing the parsed XML data
are regularly returned by rcrly calls. Parsed rcrly results have the following:

* a tag
* attributes
* contents (which may itself contain nested tag/attrs/contents)

As such, many results are often 3-tuples. rcrly includes functions (see below)
for working with this 3-tuple data.

The rcrly LFE library distinguishes between two different result types:

* multi-valued
* single-valued


Multi-valued results are simply results that have items in a lis. Many rcrly API
calls will return a list of items, for example, ``get-all-invoices/0``,
``get-plans/0``, or ``get-accounts/0``. The rcrly library provides ``map`` and
``foldl`` functions for easily working with these results.

By single-value results, we mean API calls which *do not* return a list of
values, but intstead return a single-item data structure. Examples of API calls
which do this are ``get-account/1``, ``get-billing-info/1``, ``get-plan/1``,
etc. The rcrly library provides functions like ``get-in`` and ``get-linked`` for
easily working with these results.


## Format

> A standard Recurly XML result:

```xml
<account href="https://yourname.recurly.com/v2/accounts/1">
  <adjustments href="https://yourname.recurly.com/v2/accounts/1/adjustments"/>
  <billing_info href="https://yourname.recurly.com/v2/accounts/1/billing_info"/>
  <invoices href="https://yourname.recurly.com/v2/accounts/1/invoices"/>
  <redemption href="https://yourname.recurly.com/v2/accounts/1/redemption"/>
  <subscriptions href="https://yourname.recurly.com/v2/accounts/1/subscriptions"/>
  <transactions href="https://yourname.recurly.com/v2/accounts/1/transactions"/>
  <account_code>1</account_code>
  <state>active</state>
  <username nil="nil"></username>
  <email>verena@example.com</email>
  <first_name>Verena</first_name>
  <last_name>Example</last_name>
  <company_name></company_name>
  <vat_number nil="nil"></vat_number>
  <tax_exempt type="boolean">false</tax_exempt>
  <address>
    <address1>108 Main St.</address1>
    <address2>Apt #3</address2>
    <city>Fairville</city>
    <state>WI</state>
    <zip>12345</zip>
    <country>US</country>
    <phone nil="nil"></phone>
  </address>
  <accept_language nil="nil"></accept_language>
  <hosted_login_token>a92468579e9c4231a6c0031c4716c01d</hosted_login_token>
  <created_at type="datetime">2011-10-25T12:00:00</created_at>
</account>
```

> Here is that same result as parsed by the LFE rcrly library:

```cl
#(account
  (#(href "https://yourname.recurly.com/v2/accounts/1"))
  (#(adjustments
     (#(href "https://yourname.recurly.com/v2/accounts/1/adjustments"))
     ())
   #(invoices
     (#(href "https://yourname.recurly.com/v2/accounts/1/invoices"))
     ())
   #(subscriptions
     (#(href "https://yourname.recurly.com/v2/accounts/1/subscriptions"))
     ())
   #(transactions
     (#(href "https://yourname.recurly.com/v2/accounts/1/transactions"))
     ())
   #(account_code () ("1"))
   #(state () ("active"))
   #(username () ())
   #(email () ("verena@example.com"))
   #(first_name () ("Verena"))
   #(last_name () ("Example"))
   #(company_name () ())
   #(vat_number (#(nil "nil")) ())
   #(tax_exempt (#(type "boolean")) ("false"))
   #(address ()
     (#(address1 () ("108 Main St."))
      #(address2 () ("Apt #3"))
      #(city () ("Fairville"))
      #(state () ("WI"))
      #(zip () ("12345"))
      #(country () ("US"))
      #(phone (#(nil "nil")) ())))
   #(accept_language (#(nil "nil")) ())
   #(hosted_login_token () ("a92468579e9c4231a6c0031c4716c01d"))
   #(created_at (#(type "datetime")) ("2011-10-25T12:00:00"))))
```

As noted above, the format of the results depend upon what value you have passed
as the ``return-type``; by default, the ``data`` type is passed and this simply
returns the data requested by the particular API call (not the headers, HTTP
status, body, XML conversion info, etc. -- if you want that, you'll need to pass
the ``full`` value associated with the ``return-type``).

The API calls return XML that has been parsed and converted to LFE data
structures by the [erlsom](https://github.com/willemdj/erlsom) library.

The rcrly library offers a couple of convenience functions for extracting data
from this sort of structure -- see the next two sections for more information
about data extraction.

## ``get-data``

> First, get some data using the ``full`` return type:

```cl
> (set `#(ok ,results) (rcrly:get-accounts `(#(return-type full))))
```

> Results:

```cl
#(ok
  (#(response ok)
   #(status #(200 "OK"))
   #(headers (...))
   #(body
     (#(tag "accounts")
      #(attr (#(type "array")))
      #(content
        #(accounts ...))))))
```

> Example ``get-data`` call:

```cl
> (rcrly:get-data results)
#(accounts
  (#(type "array"))
  (#(account ...)
   #(account ...)))
```
   
The ``get-data`` utility function is provided in the ``rcrly`` module and is
useful for extracing response data returned from client requests made with
the ``full`` option. It assumes a nested property list structure with the
``content`` key in the ``body``'s property list.

Though this is useful when dealing with response data from ``full`` the return
type, you may find that it is more convenient to use the default ``data`` return
type with the ``rcrly:get-in`` function instead, as it allows you to extract
just the data you need. See below for an example.


## ``get-in``

> Get some data:

```cl
> (set `#(ok ,account) (rcrly:get-account 1))
```

> Results:

```cl
#(ok
  #(account
    (#(href ...))
    (#(adjustments ...)
    ...
    #(address ()
     (...
      #(city () ("Fairville"))
      ...))
    ...)))
```

> Example ``get-in`` call:

```cl
> (rcrly:get-in '(account address city) account)
"Fairville"
```

> Note that the ``city`` field is nested in the ``address`` field. The ``address`` data
is nested in the ``account``.

The utillity function ``rcrly:get-in`` is inspired by the Clojure ``get-in``
function, but in this case, tailored to work with the rcrly results which have
been converted from XML to LFE/Erlang data structures. With a single call, you
are able to retrieve data which is nested at any depth, providing just the keys
needed to locate it.


## ``get-linked``

> Using the same account data as tthe last example, here's how you get the linked
transactions:

```cl
> (rcrly:get-linked '(account transactions) account)
#(ok
  #(transactions
    (#(type "array"))
    (#(transaction ...)
     #(transaction ...)
     #(transaction ...)
     ...)))
```

In the Recurly REST API, data relationships are encoded in media links, per
common best REST practices. Linked data may be retreived easily using the
``get-linked/2`` utility function (analog to the ``get-in/2`` function).
``get-linked/2`` performs most of the same work that ``get-in/2`` does, with
the exception being that the last item in the list of keys points to linked
data. As such, ``get-linked/2`` will then perform an HTTP ``GET`` for the
linked media.


## ``map`` and ``foldl``

> Example ``map/2`` call that lists all the plan names in the
system:

```cl
> (rcrly:map
    (lambda (x)
      (rcrly:get-in '(plan name) x))
    (rcrly:get-plans))
```

> Results:

```
("Silver Plan" "Gold plan" "30-Day Free Trial")
```

> Example ``foldl/3`` call that gets the total of all invoices
(ignoring currency type), starting with an "add" function:

```cl
> (defun add-invoice (invoice subtotal)
    (+ subtotal
      (/ (list_to_integer
           (rcrly:get-in '(invoice total_in_cents) invoice))
         100)))
add-invoice
```

> Now to use that function with ``rcrly:foldl/3``:

```cl
> (rcrly:foldl
    #'add-invoice/2
    0
    (rcrly:get-all-invoices))
```

> Result:

```cl
120.03
```

Recurly's API is XML-based, so parsed results have the following:
 * a tag
 * attributes
 * contents (which may itself contain nested tag/attrs/contents)

The ``map/2`` and ``foldl/3`` functions provided by rcrly aim to make working
with these results easier, especially for iterating through multi-valued
results.

It is important to note: ``map/2`` and ``foldl/3`` both take a *complete
result* -- this inlcudes the ``#(ok ...)``.



## Composing Results

> To use the ``->>`` macro we'll need to slurp a file that has included it:

```cl
> (slurp "src/rcrly.lfe")
#(ok rcrly)
>
```

> We're going to need some helper functions:

```cl
> (defun get-xacts (acct)
    (rcrly:get-linked '(account transactions) acct))
get-xacts
> (defun check-xacts (xacts)
    (rcrly:map #'check-xact/1 xacts))
check-xacts
> (defun check-xact (xact)
    (if (=/= (rcrly:get-in '(transaction recurring) xact) "true")
        (if (=:= (rcrly:get-in '(transaction status) xact) "success")
            (rcrly:get-in '(transaction uuid) xact))))
check-xact
> (defun id?
    ((id) (when (is_list id))
     'true)
    ((x) x))
id?
>
```

> Now we can perform our defined task:

```cl
> (->> (rcrly:get-accounts)        ; this returns a multi-valued result
       (rcrly:map #'get-xacts/1)   ; this returns a list of multi-valued results
       (lists:map #'check-xacts/1) ; this returns a list of lists
       (lists:foldl #'++/2 '())    ; this flattns the list, preserving strings
       (lists:filter #'id?/1))     ; just returns results that are ids
```

> Results:

```
("2d9d1054c2716a3d38260146d28ebc7c"
 "2dc20791440f9313a877414fe1a6f7a4"
 "2dc2076ab55c2054cfaf3b427589437a"
 "2dbc6c2d09c5aed53a9ede41138f63df"
 "2dbc6c17524ca5cda869684a6bb7aae3")
```

> Of the 12 transactions in the accounts this was tested against, those five
satisfied the criteria of being non-recurring and in a successful state.

This section might be more accurately called "processing results through
function composition" but that was a bit long. We hope you'll forgive the
poetic license we took!

With that said, here's an example of a potential "data flow" using function
composition to get the following:

* get a list of all the accounts
* for each account, get all of its transactions
* for each transaction, check to see that it's not recurring
* return the transaction id for each recurring transation which has a "success" state

<aside class="success">
If you'd like to use the ``->>`` macro in your own modules, be sure to include
it there with ``(include-lib "lutil/include/compose.lfe")``.
</aside>

<aside class="info">
Keep in mind that when using the ``->>``
macro, the output of the first function is added as a final argument to the
next function.
</aside>

<aside class="info">
The example to the right is intended to show the possibilities of composition, and the following
should be noted about the above code:
<ul><li>by getting the accounts first, we could have performed additional checks
   against account data; and</li>
<li>if we had really wanted to check all the transactions without looking
   at any of the account data, we would have simply used the
   ``get-all-transactions`` rcrly API call.</li>
   </ul>
</aside>


## Batched Results and Paging

TBD


## Relationships and Linked Data

In the Recurly REST API, data relationships are encoded in media links, per
common best REST practices. Linked data may be retreived easily using the
``get-linked/2`` utility function (analog to the ``get-in/2`` function).

For more information, see the ``get-linked`` section above.

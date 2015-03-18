# rcrly

<img src="resources/images/recurly-logo-small.png" />

*An Erlang/LFE Client for the Recurly Billing REST API*

## Table of Contents

* [Introduction](#introduction-)
  * [About Recurly](#about-recurly-)
  * [The LFE Client Library](#the-lfe-client-library-)
* [Installation](#installation-)
* [Usage](#usage-)
  * [Configuration](#configuration-)
  * [Starting rcrly](#starting-rcrly-)
  * [Authentication](#authentication-)
  * [Making Calls](#making-calls-)
    * [From LFE](#from-lfe-)
    * [From Erlang](#from-erlang-)
    * [Options](#options-)
  * [Working with Results](#working-with-results-)
    * [Format](#format-)
    * [get-data](#get-data-)
    * [get-in](#get-in-)
    * [Batched Results and Paging](#batched-results-and-paging-)
    * [Relationships and Linked Data](#relationships-and-linked-data-)
  * [Handling Errors](#handling-errors-)
    * [HTTP Errors](#http-errors-)
    * [rcrly Errors](#rcrly-errors-)
    * [lhttpc Errors](#lhttpc-errors-)
  * [Logging](#logging-)
  * [The API](#the-api-)
    * [Accounts](#accounts-)
    * [Adjustments](#adjustments-)
    * [Billing Info](#billing-info-)
    * Coupons
    * Coupon Redemptions
    * [Invoices](#invoices-)
    * Plans
    * Plan Add-ons
    * Subscriptions
    * [Transactions](#transactions-)


## Introduction [&#x219F;](#table-of-contents)

### About Recurly [&#x219F;](#table-of-contents)

From the Recurly [docs site](https://docs.recurly.com/):

<blockquote>Recurly provides a complete recurring billing system designed to remove all the headaches from subscription billing. Whether you’ve integrated with our Hosted Payment Pages, Recurly.js embedded forms, or API, these documents will help manage your day-to-day billing.
</blockquote>

### The LFE Client Library [&#x219F;](#table-of-contents)

TBD

## Installation [&#x219F;](#table-of-contents)

Just add it to your ``rebar.config`` deps:

```erlang
  {deps, [
    ...
    {rcrly, ".*",
      {git, "git@github.com:cinova/rcrly.git", "master"}}
      ]}.
```

Or, if you use ``lfe.config``:

```lisp
#(project (#(deps (#("cinova/rcrly" "master")))))
```

And then do the usual:

```bash
    $ make get-deps
    $ make compile
```


## Usage [&#x219F;](#table-of-contents)

### Configuration [&#x219F;](#table-of-contents)

The LFE rcrly library supports two modes of configuration:
* OS environment variables
* the use of ``~/.rcrly/lfe.ini``

OS environment variables take precedence over values in the configuration file.
If you would like to use environment variables, the following may be set:

* ``RECURLY_API_KEY``
* ``RECURLY_HOST`` (e.g., ``yourname.recurly.com``)
* ``RECURLY_DEFAULT_CURRENCY``
* ``RECURLY_VERSION``
* ``RECURLY_REQUEST_TIMEOUT``

You have the option of using values stored in a configuration file, instead.
This project comes with a sample configuration file you can copy and then edit:

```bash
cp sample-lfe.ini ~/.rcrly/lfe.ini
```
Or you can just use the following as a template:

```ini
[REST API]
key = GFEDCBA9876543210
host = yourname.recurly.com
timeout = 10000
version = v2
```

If neither of these methods is used to set a given variable, the default which
is hard-coded in ``src/rcrly-cfg.lfe`` will be used -- and in the case of the
API key or host this is almost certainly not what you want!


### Starting ``rcrly`` [&#x219F;](#table-of-contents)

The ``make`` targets for both the LFE REPL and the Erlang shell start rcrly
automatically. If you didn't use either of those, then you will need to
execute the following before using rcrly:

```lisp
> (rcrly:start)
(#(gproc ok)
 #(econfig ok)
 #(inets ok)
 #(ssl ok)
 #(lhttpc ok))
```
At that point, you're ready to start making calls.

If you're not in the REPL and you will be using this library programmatically,
you will want to make that call when your application starts.


### Authentication [&#x219F;](#table-of-contents)

In your OS shell, export your Recurly API key and your subdomain, e.g.:

```bash
$ export RECURLY_API_KEY=GFEDCBA9876543210
$ export RECURLY_HOST=yourname.recurly.com
```

Or be sure to have these defined in your ``~/.rcrly/lfe.ini`` file:

```ini
[REST API]
key = GFEDCBA9876543210
host = yourname.recurly.com
```

When you run the REPL or start the application from your shell, these will be
used to create the authentiction header in every call made to the REST API,
per the specifications of the Recurly service.


### Making Calls [&#x219F;](#table-of-contents)

This ``README`` won't document all the API calls availale with the service, as
that is already done by Recurly [here](https://docs.recurly.com/api/).
However, see below for some example usage to get starting using ``rcrly``
quickly.


#### From LFE [&#x219F;](#table-of-contents)

Calls from LFE are pretty standard:

```lisp
> (rcrly:get-accounts)
#(ok
  (#(account ...)
   #(account ...)
   ...))
```

#### From Erlang [&#x219F;](#table-of-contents)

Through written in LFE, the rcrly API is 100% Erlang Core compatible. You use
it just like any other Erlang library.

When you start rcrly with the make target, the depenendent applications are
started for you automatically:

```bash
$ make shell-no-deps
```

```erlang
1> rcrly:'get-accounts'().
{ok,[{account, [...]},
     {account, [...]},
     ...]}
```

#### Options [&#x219F;](#table-of-contents)

The rcrly client supports the following options which may be passed as
an optional argument (as a property list) to ``get`` and ``post``
functions:
* ``batch-size`` - [NOT YET SUPPORTED] an integer between ``1`` and ``200``
  representing the number of results returned in the Recurly service responses;
  defaults to ``20``.
* ``follow-links`` - [NOT YET SUPPORTED] a boolean representing whether linked
  data should be automatically quereied and added to the results; defaults to
  ``false``.
* ``return-type`` - what format the client calls shoudl take. Can be one of
  ``data``, ``full``, or ``xml``; the default  is ``data``.


##### ``batch-size`` [&#x219F;](#table-of-contents)

TBD

##### ``follow-links`` [&#x219F;](#table-of-contents)

TBD

##### ``return-type`` [&#x219F;](#table-of-contents)

When the ``return-type`` is set to ``data`` (the default), the data from the
response is what is returned:

```lisp
> (rcrly:get-account 1 `(#(return-type data)))
#(ok
  (#(adjustments ...)
   #(invoices ...)
   #(subscriptions ...)
   #(transactions ...)
   #(account_code () ("1"))
   ...
   #(address ...)
   ...))
```

When the ``return-type`` is set to ``full``, the response is annotated and
returned:

```lisp
> (rcrly:get-account 1 `(#(return-type full)))
#(ok
  (#(response ok)
   #(status #(200 "OK"))
   #(headers ...)
   #(body
     (#(tag "account")
      #(attr (#(href "https://yourname.recurly.com/v2/accounts/1")))
      #(content
        #(account
          (#(adjustments ...)
           #(invoices ...)
           #(subscriptions ...)
           #(transactions ...)
           ...
           #(account_code () ("1"))
           ...
           #(address ...)
           ...)))
      #(tail "\n")))))
```

When the ``return-type`` is set to ``xml``, the "raw" binary value is returned,
as it is obtained from ``lhttpc``, without modification or any parsing:

```lisp
> (rcrly:get-account 1 `(#(return-type xml)))
#(ok
  #(#(200 "OK")
    (#("strict-transport-security" "max-age=15768000; includeSubDomains")
     #("x-request-id" "ac52s06cmfugp9oauclg")
     #("cache-control" "max-age=0, private, must-revalidate")
     ...)
    #B(60 63 120 109 108 32 118 101 114 115 105 111 110  ...)))
```

If you wish to pass general HTTP client options to lhttpc, then you will need to use
``rcrly-httpc:request/7``, which takes the following arguments:

```
endpoint method headers body timeout options lhttpc-options
```

where ``options`` are the rcrly options discussed above, and ``lhttpc-options``
are the regular lhttpc options, the most significant of which are:

* ``connect_options`` - a list of terms
* ``send_retry`` - an integer
* ``partial_upload`` - an integer (window size)
* ``partial_download`` - a list of one or both of ``#(window_size N)`` and ``#(part_size N)``
* ``proxy`` - a URL string
* ``proxy_ssl_options`` - a list of terms
* ``pool`` - pid or atom


### Working with Results [&#x219F;](#table-of-contents)

All results in rcrly are of the form ``#(ok ...)`` or ``#(error ...)``, with the
elided contents of those tuples changing depending upon context. This is the
standard approach for Erlang libraries, so should be quite familiar to users.


#### Format [&#x219F;](#table-of-contents)

As noted above, the format of the results depend upon what value you have passed
as the ``return-type``; by default, the ``data`` type is passed and this simply
returns the data requested by the particular API call (not the headers, HTTP
status, body, XML conversion info, etc. -- if you want that, you'll need to pass
the ``full`` value associated with the ``return-type``).

The API calls return XML that has been parsed and converted to LFE data
structures by the [erlsom](https://github.com/willemdj/erlsom) library.

For instance, here's what a standard Recurly XML result looks like:

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

And here is that same result from the LFE rcrly library:

```lisp
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

The rcrly library offers a couple of convenience functions for extracting data
from this sort of structure -- see the next two sections for more information
about data extraction.

#### ``get-data`` [&#x219F;](#table-of-contents)

The ``get-data`` utility function is provided in the ``rcrly`` module and is
useful for extracing response data returned from client requests made with
the ``full`` option. It assumes a nested property list structure with the
``content`` key in the ``body``'s property list.

Example usage:

```lisp
> (set `#(ok ,results) (rcrly:get-accounts `(#(return-type full))))
#(ok
  (#(response ok)
   #(status #(200 "OK"))
   #(headers (...))
   #(body
     (#(tag "accounts")
      #(attr (#(type "array")))
      #(content
        #(accounts ...))))))

> (rcrly:get-data results)
#(accounts
  (#(type "array"))
  (#(account ...)
   #(account ...)))
```

Though this is useful when dealing with response data from ``full`` the return
type, you may find that it is more convenient to use the default ``data`` return
type with the ``rcrly:get-in`` function instead, as it allows you to extract
just the data you need. See below for an example.


#### ``get-in`` [&#x219F;](#table-of-contents)

The utillity function ``rcrly:get-in`` is inspired by the Clojure ``get-in``
function, but in this case, tailored to work with the rcrly results which have
been converted from XML to LFE/Erlang data structures. With a single call, you
are able to retrieve data which is nested at any depth, providing just the keys
needed to locate it.

Here's an example:

```lisp
> (set `#(ok ,account) (rcrly:get-account 1))
#(ok
  #(account
    (#(href ...))
    (#(adjustments ...)
     ...)))
> (rcrly:get-in '(account address city) account)
"Fairville"
```

The ``city`` field is nested in the ``address`` field. The ``address`` data
is nested in the ``account``.


#### Batched Results and Paging [&#x219F;](#table-of-contents)

TBD


#### Relationships and Linked Data [&#x219F;](#table-of-contents)

TBD


### Handling Errors [&#x219F;](#table-of-contents)

As mentioned in the "Working with Results" section, all parsed responses from
Recurly are a tuple of either ``#(ok ...)`` or ``#(error ...)``. All processing
of rcrly results should pattern match against these typles, handling the error
cases as appropriate for the application using the rcrly library.

#### HTTP Errors [&#x219F;](#table-of-contents)

[more to come, examples, etc.]


#### rcrly Errors [&#x219F;](#table-of-contents)

[more to come, examples, etc.]


#### lhttpc Errors [&#x219F;](#table-of-contents)

[more to come, examples, etc.]


### Logging [&#x219F;](#table-of-contents)

TBD


### The API [&#x219F;](#table-of-contents)

[NOTE: This is a work in progress]

For each of the API functions listed below, be sure to examine the linked
Recurly documentation for information about payloads.

#### Accounts [&#x219F;](#table-of-contents)

Recurly [Accounts documentation](https://docs.recurly.com/api/accounts)

##### ``get-accounts``

```lisp
> (set `#(ok ,accounts) (rcrly:get-accounts))
#(ok
  (#(account ...)
   #(account ...)))
> (length accounts)
2
```

##### ``get-account``

Takes a single arguement and returns
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

#### Adjustments [&#x219F;](#table-of-contents)

Recurly [Adjustments documentation](https://docs.recurly.com/api/adjustments)

##### ``get-adjustments``

##### ``get-adjustment``

#### Billing Info [&#x219F;](#table-of-contents)

Recurly [Billing Info documentation](https://docs.recurly.com/api/billing-info)

##### ``get-billing-info``

#### Invoices [&#x219F;](#table-of-contents)

Recurly [Invoices documentation](https://docs.recurly.com/api/invoices)

##### ``get-all-invoices``

##### ``get-invoices``

#### Transactions [&#x219F;](#table-of-contents)

Recurly [Transactions documentation](https://docs.recurly.com/api/transactions)

##### ``get-all-transactions``

##### ``get-transactions``

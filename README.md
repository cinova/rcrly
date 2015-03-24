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
    * [get-linked](#get-linked-)
    * [Batched Results and Paging](#batched-results-and-paging-)
    * [Relationships and Linked Data](#relationships-and-linked-data-)
  * [Creating Payloads](#creating-payloads-)
  * [Handling Errors](#handling-errors-)
    * [Recurly Errors](#recurly-errors-)
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
    * [Plans](#plans-)
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
* ``return-type`` - what format the client calls should take. Can be one of
  ``data``, ``full``, or ``xml``; the default  is ``data``.
* ``log-level`` - sets the log level on-the-fly, for easy debugging on a
  per-request basis
* ``endpoint`` - whether the request being made is against an API endpoint
  or a raw URL (defaults to ``true``)


##### ``batch-size`` [&#x219F;](#table-of-contents)

TBD

##### ``follow-links`` [&#x219F;](#table-of-contents)

TBD

##### ``return-type`` [&#x219F;](#table-of-contents)

When the ``return-type`` is set to ``data`` (the default), the data from the
response is what is returned:

```lisp
> (rcrly:get-account 1 '(#(return-type data)))
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
> (rcrly:get-account 1 '(#(return-type full)))
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
> (rcrly:get-account 1 '(#(return-type xml)))
#(ok
  #(#(200 "OK")
    (#("strict-transport-security" "max-age=15768000; includeSubDomains")
     #("x-request-id" "ac52s06cmfugp9oauclg")
     #("cache-control" "max-age=0, private, must-revalidate")
     ...)
    #B(60 63 120 109 108 32 118 101 114 115 105 111 110  ...)))
```

##### ``log-level`` [&#x219F;](#table-of-contents)

```lisp
(rcrly:get-account 1 '(#(log-level debugl)))
```

##### ``endpoint`` [&#x219F;](#table-of-contents)

If you wish to make a request to a full URL, you will need to pass the option
``#(endpoint false)`` to override the default behaviour of the rcrly library
creating the URL for you, based upon the provided endpoint.

In other words, one would normally make this sort of call:

```lisp
> (rcrly:get "/some/recurly/endpoint")
```

And the ``endpoint`` option is needed if you want to access a full URL:

```lisp
> (set options '(#(endpoint false)))
> (rcrly:get "https://some.domain/path/to/resource" options)
```


##### Options for lhttpc [&#x219F;](#table-of-contents)

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
    ...
    #(address ()
     (...
      #(city () ("Fairville"))
      ...))
    ...)))
> (rcrly:get-in '(account address city) account)
"Fairville"
```

The ``city`` field is nested in the ``address`` field. The ``address`` data
is nested in the ``account``.


#### ``get-linked`` [&#x219F;](#table-of-contents)


In the Recurly REST API, data relationships are encoded in media links, per
common best REST practices. Linked data may be retreived easily using the
``get-linked/2`` utility function (analog to the ``get-in/2`` function).

Here's an example showing getting account data, and then getting data
which is linked to the account data via ``href``s:

```lisp
> (set `#(ok ,account) (rcrly:get-account 1))
#(ok
  #(account ...))
> (rcrly:get-linked '(account transactions) account)
#(ok
  #(transactions
    (#(type "array"))
    (#(transaction ...)
     #(transaction ...)
     #(transaction ...)
     ...)))
```

#### Batched Results and Paging [&#x219F;](#table-of-contents)

TBD


#### Relationships and Linked Data [&#x219F;](#table-of-contents)

In the Recurly REST API, data relationships are encoded in media links, per
common best REST practices. Linked data may be retreived easily using the
``get-linked/2`` utility function (analog to the ``get-in/2`` function).

For more information, see the ``get-linked`` section above.

### Creating Payloads [&#x219F;](#table-of-contents)

Payloads for ``PUT`` and ``POST`` data in the Recurly REST API are XML
documents. As such, we need to be able to create XML for such things as
update actions. To facilitate this, The LFE rcrly library provides
XML-generating macros. in the REPL, you can ``slurp`` the ``rcrly-xml``
module, and then have access to them. For instance:

```lisp
> (slurp "src/rcrly-xml.lfe")
#(ok rcrly-xml)
```

Now you can use the rcrly macros to create XML in LFE syntax:

```lisp
> (xml/account (xml/company_name "Bob's Red Mill"))
"<account><company_name>Bob's Red Mill</company_name></account>"
```

This also works for modules that will be genereating XML payloads: simply
``include-lib`` them like they are in ``rcrly-xml``:

```lisp
(include-lib "rcrly/include/xml.lfe")
```

And then they will be available in your module.

Here's a sample payload from the
[Recurly docs](https://docs.recurly.com/api/billing-info#update-billing-info-credit-card)
(note that multiple children need to be wrapped in a ``list``):

```lisp
> (xml/billing_info
    (list (xml/first_name "Verena")
          (xml/last_name "Example")
          (xml/number "4111-1111-1111-1111")
          (xml/verification_value "123")
          (xml/month "11")
          (xml/year "2015")))
"<billing_info>
  <first_name>Verena</first_name>
  <last_name>Example</last_name>
  <number>4111-1111-1111-1111</number>
  <verification_value>123</verification_value>
  <month>11</month>
  <year>2015</year>
</billing_info>"
```


### Handling Errors [&#x219F;](#table-of-contents)

As mentioned in the "Working with Results" section, all parsed responses from
Recurly are a tuple of either ``#(ok ...)`` or ``#(error ...)``. All processing
of rcrly results should pattern match against these typles, handling the error
cases as appropriate for the application using the rcrly library.


#### Recurly Errors [&#x219F;](#table-of-contents)

The Recurly API will return errors under various circumstances. For instance,
an error is returned when attempting to look up billing information with a
non-existent account:

```lisp
> (set `#(error ,error) (rcrly:get-billing-info 'noaccountid))
#(error
  #(error ()
    (#(symbol () ("not_found"))
     #(description
       (#(lang "en-US"))
       ("Couldn't find Account with account_code = noaccountid")))))
```

You may use the ``get-in`` function to extract error information:

```lisp
> (rcrly:get-in '(error description) error)
"Couldn't find Account with account_code = noaccountid"
```

#### HTTP Errors [&#x219F;](#table-of-contents)

Any HTTP request that generates an HTTP status code equal to or greater than
400 will be converted to an error. For example, requesting account information
with an id that no account has will generate a ``404 - Not Found`` which will
be converted by rcrly to an application error:

```lisp
> (set `#(error ,error) (rcrly:get-account 'noaccountid))
#(error
  #(error ()
    (#(symbol () ("not_found"))
     #(description
       (#(lang "en-US"))
       ("Couldn't find Account with account_code = noaccountid")))))
```
```lisp
> (rcrly:get-in '(error description) error)
"Couldn't find Account with account_code = noaccountid"
```


#### rcrly Errors [&#x219F;](#table-of-contents)

[more to come, examples, etc.]


#### lhttpc Errors [&#x219F;](#table-of-contents)

[more to come, examples, etc.]


### Logging [&#x219F;](#table-of-contents)

rcrly uses the LFE logjam library for logging. The log level may be configured
in two places:

* an ``lfe.config`` file (this is the standard location for logjam)
* on a per-request basis in the ``options`` arguement to API calls

The default log level is ``emergency``, so you should never notice it's there
(unless, of course, you have lots ot logging defined for the ``emergency``
level ...). The intended use for rcrly logging is on a per-request basis for
debugging purposes (though, of course, this may be easily overridden in your
application code by setting the log level you desire in the ``lfe.config``
file).

Note that when passing the ``log-level`` option in an API call, it sets the
log level for the logging service which is running in the background. As such,
the ``log-level`` option does not need to be passed again until you wish to
change it. In other words, when passed as an option, it is set for all future
API calls.

For more details on logging per-request, see the "Options" section above.


### The API [&#x219F;](#table-of-contents)

Each API call has a default arity and then an arity+1 where the "+1" is an
argument for rcrly client options (see the "Options" section above).

For each of the API functions listed below, be sure to examine the linked
Recurly documentation for information about payloads.

#### Accounts [&#x219F;](#table-of-contents)

Recurly [Accounts documentation](https://docs.recurly.com/api/accounts)

##### ``get-accounts``

Get all accounts.

```lisp
> (set `#(ok ,accounts) (rcrly:get-accounts))
#(ok
  (#(account ...)
   #(account ...)))
> (length accounts)
2
```

##### ``get-account``

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

##### ``create-account``

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

##### ``update-account``

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

##### ``close-account``

Takes an account id.

```lisp
> (set `#(ok) (rcrly:close-account 123))
[response TBD]
```

#### Adjustments [&#x219F;](#table-of-contents)

Recurly [Adjustments documentation](https://docs.recurly.com/api/adjustments)

##### ``get-adjustments``

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

##### ``get-adjustment``

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

#### Billing Info [&#x219F;](#table-of-contents)

Recurly [Billing Info documentation](https://docs.recurly.com/api/billing-info)

##### ``get-billing-info``

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

##### ``update-billing-info``

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

#### Invoices [&#x219F;](#table-of-contents)

Recurly [Invoices documentation](https://docs.recurly.com/api/invoices)

##### ``get-all-invoices``

##### ``get-invoices``

#### Plans [&#x219F;](#table-of-contents)

Recurly [Invoices documentation](https://docs.recurly.com/api/plans)

##### ``get-plans``

##### ``get-plan``

##### ``create-plan``

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

##### ``update-plan``

##### ``delete-plan``

To delete a plan, simply pass the plan code to ``delete-plan``:

```lisp
> (set `#(ok ,results) (rcrly:delete-plan "gold"))
[response TBD]
```

#### Transactions [&#x219F;](#table-of-contents)

Recurly [Transactions documentation](https://docs.recurly.com/api/transactions)

##### ``get-all-transactions``

##### ``get-transactions``


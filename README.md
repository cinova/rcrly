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
  * [Working with Results](#working-with-results-)
    * [get-data](#get-data-)
    * [get-in](#get-in-)
    * [Batched Results and Paging](#batched-results-and-paging-)
    * [Relationships and Linked Data](#relationships-and-linked-data-)
  * [Handling Errors](#handling-errors-)
  * [Logging](#loggin-)


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
(#(inets ok) #(ssl ok) #(lhttpc ok))
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

When you run the REPL or start the application from your shell, this will be
used to create the authentiction header in every call.


### Making Calls [&#x219F;](#table-of-contents)

[NOTE: This is a work in progress]

This ``README`` won't document all the API calls availale with the service, as
that is already done by Recurly [here](https://docs.recurly.com/api/).
However, see below for some example usage to get starting using ``rcrly``
quickly.


#### From LFE [&#x219F;](#table-of-contents)

Calls from LFE are pretty standard:

```lisp
> (rcrly:start)
(#(inets ok) #(ssl ok) #(lhttpc ok))
> (rcrly:get-accounts)
(#(response ok)
 #(status #(200 "OK"))
 #(headers ...)
 #(body ...))
```

If you started the LFE REPL using the rcrly ``Makefile``, e.g.:

```bash
$ make repl-no-deps
```

then rcrly was started automatically, and you don't need to call ``(rcrly:start)``.


``response``, ``status``, ``headers``, and ``body`` are returned in all calls,
since these are often used to make subsequent calls to the Recurly services.
``response`` is useful for pattern matching against ``ok`` or ``error`` results;
``status`` is useful for matching against specific HTTP response codes.


#### From Erlang [&#x219F;](#table-of-contents)

Through written in LFE, the rcrly API is 100% Erlang Core compatible. You use
it just like any other Erlang library.

When you start rcrly with the make target, the depenendent applications are
started for you automatically:

```bash
$ make shell-no-deps
```

```erlang
1> rcrly:start().
[{inets,{error,{already_started,inets}}},
 {ssl,{error,{already_started,ssl}}},
 {lhttpc,{error,{already_started,lhttpc}}}]
2> rcrly:'get-accounts'().
[{response,ok},
 {status,{200,"OK"}},
 {headers,[...]},
 {body,[{tag,"accounts"}, ...]}]
```

#### Options [&#x219F;](#table-of-contents)

The rcrly client supports the following options which may be passed as
an optional argument (as a property list) to ``get`` and ``post``
functions:
* ``batch-size`` - [NOT YET SUPPORTED] an integer between ``1`` and ``200``
  representing the number of results returned in the Recurly service responses
* ``return-type`` - either the atom ``data``, ``full``, or ``xml``. The default
  is ``data`` and it returns the most limited set of data. ``full`` returns the
  following data structure:
  ```lisp
  (#(response ...)
   #(status #(...))
   #(headers (...))
   #(body (#(tag ...)
           #(attr ...)
           #(content (...)))))
  ```
  With ``return-type`` set to ``xml`` the raw binary XML result is returned;
  this is the data in its completely unmodified form.

General HTTP client options which may be passed in the same property list
as the rcrly options. lhttpc will understand the following options:
* ``connect_options`` - a list of terms
* ``send_retry`` - an integer
* ``partial_upload`` - an integer (window size)
* ``partial_download`` - a list of one or both of ``#(window_size N)`` and ``#(part_size N)``
* ``proxy`` - a URL string
* ``proxy_ssl_options`` - a list of terms
* ``pool`` - pid or atom


#### The API [&#x219F;](#table-of-contents)

##### Accounts [&#x219F;](#table-of-contents)

Recurly [Accounts documentation](https://docs.recurly.com/api/accounts)

###### ``get-accounts``

```lisp
> (set results (rcrly:get-accounts))
(#(response ok)
 #(status #(200 "OK"))
 #(headers ...)
 #(body
   (#(tag "accounts")
    #(attr (#(type "array")))
    #(content
     (#(account ...)
      #(account ...)))
     ...)))
> 
```

###### ``get-account``

##### Adjustments [&#x219F;](#table-of-contents)

Recurly [Adjustments documentation](https://docs.recurly.com/api/adjustments)

###### ``get-adjustments``

###### ``get-adjustment``

##### Billing Info [&#x219F;](#table-of-contents)

Recurly [Billing Info documentation](https://docs.recurly.com/api/billing-info)

###### ``get-billing-info``

##### Invoices [&#x219F;](#table-of-contents)

Recurly [Invoices documentation](https://docs.recurly.com/api/invoices)

###### ``get-all-invoices``

###### ``get-invoices``

##### Transactions [&#x219F;](#table-of-contents)

Recurly [Transactions documentation](https://docs.recurly.com/api/transactions)

###### ``get-all-transactions``

###### ``get-transactions``


### Working with Results [&#x219F;](#table-of-contents)

#### ``get-data`` [&#x219F;](#table-of-contents)

The ``get-data`` utility function is provided in the ``rcrly`` module and is
useful for extracing response data from the data structure that is returned
in most rcrly client results. For example:

```lisp
> (set results (rcrly:get-accounts))
(#(response ok)
 #(status #(200 "OK"))
 #(headers ...)
 #(body ...))
> (set data (rcrly:get-data results))
(#("account" ...)
 #("account" ...))
```

Though this is useful when dealing with response data, you may find that it is
more beneficial to use the ``rcrly:get-in`` instead, as it allows you to extract
just the data you need.


#### ``get-in`` [&#x219F;](#table-of-contents)

The utillity function ``rcrly:get-in`` is inspired by the Clojure ``get-in``
function, but in this case, tailored to work with the rcrly results which have
been converted from XML to LFE/Erlang data structures. With a single call, you
are able to retrieve data which is nested at any depth, providing just the keys
needed to locate it.

Here's an example:

```lisp
> (set results (rcrly:get-account 1))
(#(response ok)
 #(status #(200 "OK"))
 #(headers ...)
 #(body ...))
> (rcrly:get-in '(address zip) results)
("12345")
```

The ``zip`` field is nested in the ``address`` field. The ``address`` data
is in the ``content`` of the ``body`` in ``results``.

#### Batched Results and Paging [&#x219F;](#table-of-contents)

TBD

#### Relationships and Linked Data [&#x219F;](#table-of-contents)

TBD

### Handling Errors [&#x219F;](#table-of-contents)

TBD


### Logging [&#x219F;](#table-of-contents)

TBD

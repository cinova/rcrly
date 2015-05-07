# Getting Started

## Installation

> Just add it to your ``rebar.config`` deps:

```erlang
  {deps, [
    ...
    {rcrly, ".*",
      {git, "git@github.com:cinova/rcrly.git", "master"}}
      ]}.
```

> Or, if you use ``lfe.config``:

```lisp
    #(project (#(deps (#("cinova/rcrly" "master")))))
```

> And then do the usual:

```bash
    $ make compile
```

To install the LFE rcrly REST client library, follow the standard rebar practics or use an ``lfe.config`` file.

## Configuration

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


## Starting ``rcrly``

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


## Authentication

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


## Making Calls

This ``README`` won't document all the API calls availale with the service, as
that is already done by Recurly [here](https://docs.recurly.com/api/).
However, see below for some example usage to get starting using ``rcrly``
quickly.


### From LFE

Calls from LFE are pretty standard:

```lisp
> (rcrly:get-accounts)
#(ok
  (#(account ...)
   #(account ...)
   ...))
```

### From Erlang

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

### Options

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


#### ``batch-size``

TBD

#### ``follow-links``

TBD

#### ``return-type``

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

#### ``log-level``

```lisp
(rcrly:get-account 1 '(#(log-level debug)))
```

#### ``endpoint``

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


#### Options for lhttpc

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

### Creating Payloads

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

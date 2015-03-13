# rcrly

<img src="resources/images/recurly-logo-small.png" />

*An Erlang/LFE REST API Client for the Recurly Billing Service*

## Table of Contents

* [Introduction](#introduction-)
* [Installation](#installation-)
* [Usage](#usage-)
  * [Configuration](#configuration-)
  * [Starting rcrly](#starting-rcrly-)
  * [Authentication](#authentication-)
  * [API Calls](#api-calls-)
    * [From LFE](#from-lfe-)
    * [From Erlang](#from-erlang-)
  * [Handling Errors](#handling-errors-)
  * [Logging](#loggin-)


## Introduction [&#x219F;](#table-of-contents)

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

And then do the usual:

```bash
    $ rebar get-deps
    $ rebar compile
```


## Usage [&#x219F;](#table-of-contents)

### Configuration [&#x219F;](#table-of-contents)

TBD

### Starting ``rcrly`` [&#x219F;](#table-of-contents)

From the REPL, you'll need to execute the following before using:

```lisp
> (rcrly:start)
(#(inets ok) #(ssl ok) #(lhttpc ok))
```
At that point, you're ready to start making calls.

If you're not in the REPL and you will be using this library programmatically,
you will want to start ``rcrly`` when your application starts.


### Authentication [&#x219F;](#table-of-contents)

TBD

### API Calls [&#x219F;](#table-of-contents)

[NOTE: This is a work in progress]

This ``README`` won't document all the API calls availale with the service, as
that is already done by Recurly [here](https://docs.recurly.com/api/).
However, see below for some example usage to get starting using ``rcrly``
quickly.

### From LFE [&#x219F;](#table-of-contents)

```lisp
> (rcrly:start)
(#(inets ok) #(ssl ok) #(lhttpc ok))
> (set data (rcrly:get "/accounts"))
(#(status #(200 "OK"))
 #(headers
   (#("strict-transport-security" "max-age=15768000; includeSubDomains")
    #("x-request-id" "ac2vfg1lpbu2ofbkn900")
    #("cache-control" "max-age=0, private, must-revalidate")
    #("etag" "\"d41d8cd98f00b204e9800998ecf8427e\"")
    #("x-records" "0")
    #("x-ratelimit-reset" "1426286160")
    #("x-ratelimit-remaining" "1999")
    #("x-ratelimit-limit" "2000")
    #("content-language" "en-US")
    #("vary" "Accept-Encoding")
    #("connection" "close")
    #("transfer-encoding" "chunked")
    #("content-type" "application/xml; charset=utf-8")
    #("date" "Fri, 13 Mar 2015 22:31:51 GMT")
    #("server" "blackhole")))
 #(body #("accounts" (#("type" "array")) ())))
> (proplists:get_value 'body data)
#("accounts" (#("type" "array")) ())
  
```

### From Erlang [&#x219F;](#table-of-contents)

TBD

### Handling Errors [&#x219F;](#table-of-contents)

TBD

### Logging [&#x219F;](#table-of-contents)

TBD

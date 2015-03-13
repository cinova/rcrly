# rcrly

![Recurly Logo](resources/images/recurly-logo-small.png")

*An Erlang/LFE REST API Client for the Recurly Billing Service*

## Table of Contents

* [Introduction](#introduction-)
* [Installation](#installation-)
* [Usage](#usage-)
  * [Configuration](#configuration-)
  * [Starting rcrly](#starting---rcrly---)
  * [Authentication](#authentication-)
  * [API Calls](#api-calls-)
    * [From LFE](#from-lfe-)
    * [From Erlang](#from-erlang-)
  * [Handling Errors](#handling-errors-)
  * [Logging](#loggin-)
  
## Introduction [&#x219F;](#table-of-contents)

Add content to me here!


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

TBD

### From LFE [&#x219F;](#table-of-contents)

TBD

### From Erlang [&#x219F;](#table-of-contents)

TBD

### Handling Errors [&#x219F;](#table-of-contents)

TBD

### Logging [&#x219F;](#table-of-contents)

TBD

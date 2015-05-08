# rcrly

<img src="resources/images/recurly-logo-small.png" />

*An Erlang/LFE Client for the Recurly Billing REST API*

## Table of Contents

* [Introduction](#introduction-)
  * [About Recurly](#about-recurly-)
  * [The LFE Client Library](#the-lfe-client-library-)
* [Installation](#installation-)
* [Usage](#usage-)


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

Usage information is provided on the [documentation site](http://cinova.github.io/rcrly/).

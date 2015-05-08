# Handling Errors

> The Recurly API will return errors under various circumstances. For instance,
an error is returned when attempting to look up billing information with a
non-existent account:

```cl
> (set `#(error ,error) (rcrly:get-billing-info 'noaccountid))
```

> Resulting error:

```
#(error
  #(error ()
    (#(symbol () ("not_found"))
     #(description
       (#(lang "en-US"))
       ("Couldn't find Account with account_code = noaccountid")))))
```

> Note that we pattern-matched against ``#(error ...)``. Also, you may use the ``get-in``
function to extract error information:

```cl
> (rcrly:get-in '(error description) error)
"Couldn't find Account with account_code = noaccountid"
```

> Any HTTP request that generates an HTTP status code equal to or greater than
400 will be converted to an error. For example, requesting account information
with an id that no account has will generate a ``404 - Not Found`` which will
be converted by rcrly to an application error:

```cl
> (set `#(error ,error) (rcrly:get-account 'noaccountid))
```

> Resulting error:

```cl
#(error
  #(error ()
    (#(symbol () ("not_found"))
     #(description
       (#(lang "en-US"))
       ("Couldn't find Account with account_code = noaccountid")))))
```

> Extracting the message:

```lisp
> (rcrly:get-in '(error description) error)
"Couldn't find Account with account_code = noaccountid"
```

> rcrly Errors: TBD

> lhttpc Errors: TBD


As mentioned in the "Working with Results" section, all parsed responses from
Recurly are a tuple of either ``#(ok ...)`` or ``#(error ...)``. All processing
of rcrly results should pattern match against these typles, handling the error
cases as appropriate for the application using the rcrly library.

There are four types of errors that rcrly aims to address:

* Errors in the Recurly service (e.g., making a bad request that the service can't serve)
* General HTTP errors
* Errors in the rcrly library
* Errors in the underlying lhttpc library

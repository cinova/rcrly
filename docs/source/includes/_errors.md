# Handling Errors

As mentioned in the "Working with Results" section, all parsed responses from
Recurly are a tuple of either ``#(ok ...)`` or ``#(error ...)``. All processing
of rcrly results should pattern match against these typles, handling the error
cases as appropriate for the application using the rcrly library.


## Recurly Errors

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

## HTTP Errors

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


## rcrly Errors

[more to come, examples, etc.]


## lhttpc Errors

[more to come, examples, etc.]

# Logging

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

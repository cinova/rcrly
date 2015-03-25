(defmodule rcrly-httpc
  (export all))

(defun request (endpoint method options)
  (request endpoint method "" options))

(defun request (endpoint method body options)
  (let ((headers (make-default-headers)))
    (logjam:debug (MODULE)
                  'request/4
                  "Using default headers:~n~p"
                  `(,headers))
    (request endpoint
             method
             headers
             body
             options)))

(defun request (endpoint method headers body options)
  (request endpoint
           method
           headers
           body
           (rcrly-cfg:get-request-timeout)
           options
           '()))

(defun request (endpoint method headers body timeout options lhttpc-options)
  "This function makes the call to the request dispatcher and checks the
  response for errors, appropriately the state of the response in the first
  element of the returned tuple."
  (logjam:debug (MODULE) 'request/7 "Request URL: ~p" `(,endpoint))
  (let* ((return-type (proplists:get_value 'return-type options 'data))
         (log-level (proplists:get_value 'log-level options (rcrly-cfg:get-log-level)))
         (_ (logjam:set-level log-level))
         (raw-response (raw-request
                         (make-url endpoint options)
                         method
                         headers
                         body
                         timeout
                         options
                         lhttpc-options))
         (status (get-response-status raw-response)))
    (case return-type
      ('data
        `#(,status ,(data-response (parsed-response raw-response))))
      ('full
        `#(,status ,(response (parsed-response raw-response))))
      ('xml
        raw-response))))

(defun raw-request (url method headers body timeout options lhttpc-options)
  "This is a low-level client function; this function should not be called
  directly as it does not differentiate between error and non-error results."
  ;; lhttpc can bomb out on an error with an exit, thus killing the LFE shell;
  ;; as such, we wrap it in a (try ...)
  (try
    (prog1
      (lhttpc:request url method headers body timeout lhttpc-options)
      (logjam:info (MODULE) 'raw-request/7 "Successfully called lhttpc."))
    (catch (('error type stacktrace)
            ;; XXX this needs to be double-checked under various error
            ;; conditions
            (logjam:info (MODULE)
                         'raw-request
                         "Error when calling lhttpc ...~nStacktrace: ~n~p"
                         `(,stacktrace))
            `(#(error `#(lhttpc ,type ,stacktrace)))))))

(defun parsed-response
  "This function parses the XML data into LFE/Erlang data structures."
  ((`#(ok #(,status ,headers #B())))
   (logjam:debug (MODULE) 'parsed-response/1 "Got empty body with 'ok'.")
   `#(ok #(,status ,headers (#(content "")))))
  ((`#(error #(,status ,headers #B())))
   (logjam:debug (MODULE) 'parsed-response/1 "Got empty body with 'error'.")
   `#(error #(,status ,headers (#(content "")))))
  ((`#(ok #(,status ,headers ,body)))
   (logjam:debug (MODULE) 'parsed-response/1 "Got body: ~p" `(,body))
   (let ((parsed (rcrly-xml:parse-body body)))
     (if (body-has-errors? parsed)
       `#(error #(,status ,headers ,parsed))
       `#(ok #(,status ,headers ,parsed))))))

(defun data-response (response)
  "This function extract only the returned data in the reponse."
  (rcrly:get-data (response response)))

(defun response
  ((`#(ok #(,status ,headers ,body)))
   `(#(response ok)
     #(status ,status)
     #(headers ,headers)
     #(body ,body)))
  ((`#(error #(,status ,headers ,body)))
   `(#(response error)
     #(status ,status)
     #(headers ,headers)
     #(body ,body)))
  (((= `#(error ,_) error))
   `(#(response error)
     #(status 'undefined)
     #(headers 'undefined)
     #(body (#(content ,error))))))

(defun get-response-status
  (((= `#(error ,_) response))
   'error)
  (((= `#(ok ,data) response))
   (let ((`#(,code ,_) (element 1 data)))
     (if (>= code 400)
       'error
       'ok))))

(defun body-has-errors?
  ((`(#(tag "errors") ,_ ,_ ,_))
   'true)
  ((x)
   'false))

(defun make-default-headers ()
  `(#("Accept" "application/xml")
    #("Content-Type" "application/xml; charset=utf-8")
    #("User-Agent" ,(rcrly-cfg:user-agent))
    #("Authorization" ,(make-auth-header))))

(defun make-auth-header ()
  (++ "Basic "
      (base64:encode_to_string (rcrly-cfg:get-api-key))))

(defun make-url (endpoint options)
  (logjam:debug (MODULE) 'make-url/2 "Got options: ~p" `(,options))
  (let ((is-endpoint? (proplists:get_value 'endpoint options 'true)))
    (if is-endpoint?
        (++ "https://"
            (rcrly-cfg:get-host)
            "/"
            (rcrly-cfg:get-remote-api-version)
            endpoint)
        endpoint)))
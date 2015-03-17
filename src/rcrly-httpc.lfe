(defmodule rcrly-httpc
  (export all))

(defun request (endpoint method options)
  (request endpoint method "" options))

(defun request (endpoint method body options)
  (request endpoint
           method
           (make-default-headers)
           body
           options))

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
  (let* ((return-type (proplists:get_value 'return-type options 'data))
         (raw-response (raw-request
                         (make-url endpoint)
                         method
                         headers
                         body
                         timeout
                         options
                         lhttpc-options))
         (status (get-response-status raw-response)))
    (case return-type
      ('data
        `#(,status ,(data-response raw-response)))
      ('full
        `#(,status ,(response raw-response)))
      ('xml
        raw-response))))

(defun raw-request (url method headers body timeout options lhttpc-options)
  "This is a low-level client function; this function should not be called
  directly as it does not differentiate between error and non-error results."
  ;; lhttpc can bomb out on an error with an exit, thus killing the LFE shell;
  ;; as such, we wrap it in a (try ...)
  (try
      (lhttpc:request url method headers body timeout lhttpc-options)
    (catch (('error type stacktrace)
            ;; XXX this needs to be double-checked under various error
            ;; conditions
            `(#(error `#(lhttpc ,type ,stacktrace)))))))

(defun data-response (response)
  "This function extract only the returned data in the reponse."
  (rcrly:get-data (response response)))

(defun response
  ((`#(ok #(,status ,headers ,body)))
   `(#(response ok)
     #(status ,status)
     #(headers ,headers)
     #(body ,(body-error-check (rcrly-xml:parse-body body) status))))
  (((= `#(error ,_) error))
   ;; XXX let's find a good error and use that to refine this one
   `(#(response error)
     #(status 'undefined)
     #(headers 'undefined)
     #(body ,error))))

(defun get-response-status
  (((= `#(error ,_) response))
   'error)
  (((= `#(ok ,data) response))
   (let ((`#(,code ,_) (element 1 data)))
     (if (>= code 400)
       'error
       'ok))))

(defun body-error-check
  ((`(#(tag "errors") ,_ ,content ,_) `#(,code ,msg))
   (error `#(code ,code message ,msg content) 'api-error))
  ((parsed staus) parsed))

(defun make-default-headers ()
  `(#("Accept" "application/xml")
    #("Content-Type" "application/xml; charset=utf-8")
    #("Authorization" ,(make-auth-header))))

(defun make-auth-header ()
  (++ "Basic "
      (base64:encode_to_string (rcrly-cfg:get-api-key))))

(defun make-url (endpoint)
  (++ "https://"
      (rcrly-cfg:get-host)
      "/"
      (rcrly-cfg:get-remote-api-version)
      endpoint))
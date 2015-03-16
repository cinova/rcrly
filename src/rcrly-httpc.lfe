(defmodule rcrly-httpc
  (export all))

(defun request (endpoint method)
  (request endpoint method ""))

(defun request (endpoint method body)
  (request endpoint
           method
           (make-default-headers)
           body))

(defun request (endpoint method headers body)
  (request endpoint
           method
           headers
           body
           (rcrly-cfg:get-request-timeout)))

(defun request (endpoint method headers body timeout)
  (request (make-url endpoint) method headers body timeout '()))

(defun request (url method headers body timeout _rcrly-state)
  ;; lhttpc can bomb out on an error with an exit, thus killing the LFE shell;
  ;; as such, we wrap it in a (try ...)
  (try
      (response
       (lhttpc:request url method headers body timeout '()))
    (catch (('error type stacktrace)
            ;; XXX this needs to be double-checked under various error conditions
            (error `#(lhttpc ,type ,stacktrace))))))

(defun response
  ((`#(ok #(,status ,headers ,body)))
    `(#(status ,status)
      #(headers ,headers)
      #(body ,(body-error-check (parse-body-xml body) status))))
  (((= `#(error ,_) error))
   ;; XXX let's find a good error and use that to refine this one
   error))

(defun parse-body-xml
  ((`#(ok #(,tag ,attributes ,content) ,tail))
   `(#(tag ,tag)
     #(attr ,attributes)
     #(content ,content)
     #(tail ,tail)))
  ((body)
   (parse-body-xml
     (erlsom:simple_form body))))

(defun body-error-check
  ((`(#(tag "errors") ,_ ,content ,_) `#(,code ,msg))
   (error #(code ,code message ,msg content) 'api-error))
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
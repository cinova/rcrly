(defmodule rcrly-httpc
  (export all))

(defun request (url method headers body timeout _rcrly-state)
  (lhttpc:request url method headers body timeout '()))

(defun response
  ((`#(ok #(#(,_http-version ,status ,status-line) ,headers ,body)))
   `#(ok #(#(,status ,status-line) ,headers ,body)))
  (((= `#(error ,_) error))
   error))

(defun make-default-headers ()
  `(#("Accept" "application/xml")
    #("Content-Type" "application/xml; charset=utf-8")
    #("Authorization" ,(make-auth-header))))

(defun make-auth-header ()
  (++ "Basic "
      (base64:encode_to_string (rcrly-cfg:get-api-key))))

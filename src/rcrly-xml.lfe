(defmodule rcrly-xml
  (export all))

(include-lib "lutil/include/compose.lfe")

(defun parse-body (body)
  (parse-body body '()))

(defun parse-body (body options)
  (if (=:= (proplists:get_value 'result-type options) 'raw)
    (parse-body-raw body)
    (parse-body-to-atoms body)))

(defun parse-body-raw
  ((`#(ok #(,tag ,attributes ,content) ,tail))
   `(#(tag ,tag)
     #(attr ,attributes)
     #(content ,content)
     #(tail ,tail)))
  ((body)
   (parse-body-raw
     (erlsom:simple_form body))))

(defun parse-body-to-atoms (body)
  (->> body
       (parse-body-raw)
       (convert-keys)))

(defun convert-keys
  "Convert property list keys to atoms."
  ((`#(,key ,val)) (when (is_list key))
    (convert-keys (tuple (list_to_atom key) val)))
  ((`#(,key ,val))
    (tuple key (convert-keys val)))
  ((`#(,tag ,attr ,content))
    (tuple (list_to_atom tag)
           (convert-keys attr)
           (convert-keys content)))
  (((cons head tail))
    (cons (convert-keys head)
          (convert-keys tail)))
  ((x) x))

(defun get-in
  "get-in assumes that the last element of the three-tuple is the one that holds
  the desired data. As this is the 'content' element of the tuple as parsed by
  erlsom, this is a reasonable assumption.

  To get attributes instead of content, get-in can be used to obtain the
  second-to-last nested value and then the attributes may be extracted from last
  one."
  (((= (cons first-key rest-keys) keys)
    (= (cons first-data rest-data) data))
   (cond ((=:= (size first-data) 2)
          (get-in-three-tuple
            rest-keys
            (lists:keyfind first-key 1 data)))
         ((=:= (size first-data) 3)
          (get-in-three-tuple keys data)))))

(defun get-in-three-tuple (keys data)
  (lists:foldl #'find/2 data keys))

(defun find (key data)
  "This is necesary since the proplists module requires 2-tuples only.

  This function assumes that the data desired is in the third (last) element
  of the three-tuple."
  (element 3 (lists:keyfind key 1 data)))
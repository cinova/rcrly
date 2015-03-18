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
     #(content #(,tag ,attributes ,content))
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
  one.

  get-in supports a list of 3-tuples but also a list of 2-tuples which contain
  3-tuples."
  ((keys data) (when (is_tuple data))
   (get-in keys (list data)))
  (((= (cons first-key rest-keys) keys)
    (= (cons first-data rest-data) data))
   (cond ((=:= (size first-data) 3)
          (get-in-3tuple keys data))
         ((=:= (size first-data) 2)
          (get-in-3tuple
            rest-keys
            (element 2 (lists:keyfind first-key 1 data)))))))

(defun one-or-all
  "This is for use in filtering results that could either contain a single
  element or a list of elements, returning just the element itself when
  the passed list only has one element."
  (((cons head '()))
   head)
  ((all)
   all))

(defun get-in-3tuple (keys data)
  (lists:foldl #'find/2 data keys))

(defun find (key data)
  "This is necesary since the proplists module requires 2-tuples only.

  This function assumes that the data desired is in the third (last) element
  of the three-tuple."
  (one-or-all
    (element 3 (lists:keyfind key 1 data))))
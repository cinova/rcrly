(defmodule unit-rcrly-tests
  (behaviour ltest-unit)
  (export all)
  (import
    (from ltest
      (check-failed-assert 2)
      (check-wrong-assert-exception 2))))

(include-lib "ltest/include/ltest-macros.lfe")

(deftest get-data
  (is-equal "some content"
            (rcrly:get-data (unit-rcrly-xml-tests:test-data-0))))

(deftest get-in
  ;; test just the standard 3-tuple data structure
  (is-equal "thing"
            (rcrly-xml:get-in '(level1-1)
                              (unit-rcrly-xml-tests:test-data-2)))
  (is-equal "brother"
            (rcrly-xml:get-in '(level1-3 level2-3)
                              (unit-rcrly-xml-tests:test-data-2)))
  (is-equal "bit"
            (rcrly-xml:get-in '(level1-3 level2-2 level3-2)
                              (unit-rcrly-xml-tests:test-data-2)))
  (is-equal "hat"
            (rcrly-xml:get-in '(level1-3 level2-2 level3-1 level4-3)
                              (unit-rcrly-xml-tests:test-data-2)))
  ;; test the 3-tuple data structure nested inside a proplist
  (is-equal "thing"
            (rcrly-xml:get-in '(key3 level1-1)
                              (unit-rcrly-xml-tests:test-data-3)))
  (is-equal "brother"
            (rcrly-xml:get-in '(key3 level1-3 level2-3)
                              (unit-rcrly-xml-tests:test-data-3)))
  (is-equal "bit"
            (rcrly-xml:get-in '(key3 level1-3 level2-2 level3-2)
                              (unit-rcrly-xml-tests:test-data-3)))
  (is-equal "hat"
            (rcrly-xml:get-in '(key3 level1-3 level2-2 level3-1 level4-3)
                              (unit-rcrly-xml-tests:test-data-3))))
#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class ExclusiveOrTestCase < AppTestCase
    def test_simple
      fname = '/proj/org/incava/glark/test/resources/textfile.txt'
      expected = [
                  "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[30m[42mTheMillersTale[0m.txt",
                  "   10   -rw-r--r--   1 jpace jpace   [30m[43m64791[0m 2010-12-04 15:24 09-TheClerksTale.txt",
                  "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[42mTheMonksTale[0m.txt",
                  "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[30m[42mTheManciplesTale[0m.txt",
                 ]
      run_app_test expected, [ '--xor', '\b6\d{4}\b', 'TheM.*Tale' ], fname
    end
  end
end

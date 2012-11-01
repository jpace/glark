#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::ExpressionFileTestCase < Glark::AppTestCase
  def test_simple
    infile = '/proj/org/incava/glark/test/resources/expressions.txt'
    file = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[30m[42mTheMillersTale[0m.txt",
                "    6   -rw-r--r--   1 jpace jpace   [30m[43m63290[0m 2010-12-04 15:24 05-[30m[42mTheManOfLawsTale[0m.txt",
                "   10   -rw-r--r--   1 jpace jpace   [30m[43m64791[0m 2010-12-04 15:24 09-TheClerksTale.txt",
                "   11   -rw-r--r--   1 jpace jpace   [30m[43m65852[0m 2010-12-04 15:24 10-[30m[42mTheMerchantsTale[0m.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[42mTheMonksTale[0m.txt",
                "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[30m[42mTheManciplesTale[0m.txt",
               ]
    run_app_test expected, [ '--file', infile ], file
  end
end

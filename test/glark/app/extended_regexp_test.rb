#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::ExtendedRegexpTestCase < Glark::AppTestCase
  def test_simple
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "   15   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-[30m[43mThePar[0mdonersTale.txt",
                "   25   -rw-r--r--   1 jpace jpace   58300 2010-12-04 15:24 24-[30m[43mThePar[0msonsTale.txt",
               ]
    run_app_test expected, [ '--extended', 'The  P a r' ], fname
  end
end

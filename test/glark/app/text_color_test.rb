#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class TextColorTestCase < AppTestCase
    def test_single
      fname = '/proj/org/incava/glark/test/resources/textfile.txt'
      expected = [
                  "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[1mTheSompnoursTale[0m.txt",
                  "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[1mTheSquiresTale[0m.txt",
                  "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[1mTheShipmansTale[0m.txt",
                  "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[1mTheSecondNunsTale[0m.txt",
                 ]
      run_app_test expected, [ '--text-color', 'bold', 'TheS.*Tale' ], fname
    end

    def test_multi
      fname = '/proj/org/incava/glark/test/resources/textfile.txt'
      expected = [
                  # go IU!
                  "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[4m[31m[47mTheSompnoursTale[0m.txt",
                  "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[4m[31m[47mTheSquiresTale[0m.txt",
                  "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[4m[31m[47mTheShipmansTale[0m.txt",
                  "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[4m[31m[47mTheSecondNunsTale[0m.txt",
                 ]
      run_app_test expected, [ '--text-color', 'underline red on white', 'TheS.*Tale' ], fname
    end
  end
end

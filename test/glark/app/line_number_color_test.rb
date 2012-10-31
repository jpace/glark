#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::LineNumberColorTestCase < Glark::AppTestCase
  def test_single
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "     [1m9[0m   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "    [1m12[0m   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "    [1m16[0m   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                "    [1m22[0m   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt",
               ]
    run_app_test expected, [ '--line-number-color', 'bold', 'TheS.*Tale' ], fname
  end

  def test_multi
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                # go Purdue!
                "     [1m[33m[40m9[0m   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "    [1m[33m[40m12[0m   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "    [1m[33m[40m16[0m   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                "    [1m[33m[40m22[0m   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt",
               ]
    run_app_test expected, [ '--line-number-color', 'bold yellow on black', 'TheS.*Tale' ], fname
  end
end

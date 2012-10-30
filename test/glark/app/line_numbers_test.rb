#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::LineNumbersTestCase < Glark::AppTestCase
  def test_glark
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "  -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "  -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "  -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                "  -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt",
               ]
    run_app_test expected, [ '-N', 'TheS\w+Tale' ], fname
  end

  def test_grep_without_numbers
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "  -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-TheSompnoursTale.txt",
                "  -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                "  -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-TheShipmansTale.txt",
                "  -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-TheSecondNunsTale.txt",
               ]
    run_app_test expected, [ '-g', 'TheS\w+Tale' ], fname
  end

  def test_grep_with_numbers
    # grep defaults to no numbers
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "9:   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-TheSompnoursTale.txt",
                "12:   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                "16:   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-TheShipmansTale.txt",
                "22:   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-TheSecondNunsTale.txt",
               ]
    run_app_test expected, [ '-g', '-n', 'TheS.*Tale' ], fname
  end
end

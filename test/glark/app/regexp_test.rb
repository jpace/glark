#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::RegexpTestCase < Glark::AppTestCase
  def test_regexp_no_context
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-[30m[43mTheKnightsTale[0m.txt",
                "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[30m[43mTheMillersTale[0m.txt",
                "    4   -rw-r--r--   1 jpace jpace   29296 2010-12-04 15:24 03-[30m[43mTheReevesTale[0m.txt",
                "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-[30m[43mTheCooksTale[0m.txt",
                "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-[30m[43mTheManOfLawsTale[0m.txt",
                "    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-[30m[43mTheWifeOfBathsTale[0m.txt",
                "    8   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-[30m[43mTheFriarsTale[0m.txt",
                "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-[30m[43mTheClerksTale[0m.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "   13   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-[30m[43mTheFranklinsTale[0m.txt",
                "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoctorsTale[0m.txt",
                "   15   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-[30m[43mThePardonersTale[0m.txt",
                "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                "   17   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-[30m[43mThePrioresssTale[0m.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[43mTheMonksTale[0m.txt",
                "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-[30m[43mTheNunsPriestsTale[0m.txt",
                "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt",
                "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-[30m[43mTheCanonsYeomansTale[0m.txt",
                "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[30m[43mTheManciplesTale[0m.txt",
                "   25   -rw-r--r--   1 jpace jpace   58300 2010-12-04 15:24 24-[30m[43mTheParsonsTale[0m.txt",
               ]
    run_app_test expected, [ 'The\w+Tale' ], fname
  end


  def test_one_line_grep
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "  -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-TheSompnoursTale.txt",
                "  -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                "  -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-TheShipmansTale.txt",
                "  -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-TheSecondNunsTale.txt",
               ]
    run_app_test expected, [ '-g', 'TheS.*Tale' ], fname
  end
end

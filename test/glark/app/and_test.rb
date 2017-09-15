#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class AndTestCase < AppTestCase
    def test_one_line
      fname = to_path "textfile.txt"
      expected = [
                  "    6   -rw-r--r--   1 jpace jpace   [30m[43m63290[0m 2010-12-04 15:24 05-[30m[42mTheManOfLawsTale[0m.txt",
                  "   10   -rw-r--r--   1 jpace jpace   [30m[43m64791[0m 2010-12-04 15:24 09-[30m[42mTheClerksTale[0m.txt",
                  "   11   -rw-r--r--   1 jpace jpace   [30m[43m65852[0m 2010-12-04 15:24 10-[30m[42mTheMerchantsTale[0m.txt",
                 ]
      run_app_test expected, [ '--and', '\b6\d{4}\b', 'The.*Tale' ], fname
    end

    def test_multi_line
      fname = to_path "textfile.txt"
      expected = [
                  "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[42mTheSquiresTale[0m.txt",
                  "   13   -rw-r--r--   1 jpace jpace   [30m[43m51996[0m 2010-12-04 15:24 12-TheFranklinsTale.txt",
                  "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-TheDoctorsTale.txt",
                  "   15   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-ThePardonersTale.txt",
                  "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[42mTheShipmansTale[0m.txt",
                  "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[42mTheSecondNunsTale[0m.txt",
                  "   23   -rw-r--r--   1 jpace jpace   [30m[43m52953[0m 2010-12-04 15:24 22-TheCanonsYeomansTale.txt",
                  "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-TheManciplesTale.txt",
                  "   25   -rw-r--r--   1 jpace jpace   [30m[43m58300[0m 2010-12-04 15:24 24-TheParsonsTale.txt",
                 ]
      run_app_test expected, [ '--and=3', '\b5\d{4}\b', 'TheS.*Tale' ], fname
    end

    def test_infinite_distance
      fname = to_path "textfile.txt"
      expected = [
                  "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-[30m[42mTheKnightsTale[0m.txt",
                  "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-TheMillersTale.txt",
                  "    4   -rw-r--r--   1 jpace jpace   29296 2010-12-04 15:24 03-TheReevesTale.txt",
                  "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-TheCooksTale.txt",
                  "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-TheManOfLawsTale.txt",
                  "    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-TheWifeOfBathsTale.txt",
                  "    8   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-TheFriarsTale.txt",
                  "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-TheSompnoursTale.txt",
                  "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-TheClerksTale.txt",
                  "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchantsTale.txt",
                  "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                  "   13   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-TheFranklinsTale.txt",
                  "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-TheDoctorsTale.txt",
                  "   15   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-ThePardonersTale.txt",
                  "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-TheShipmansTale.txt",
                  "   17   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-ThePrioresssTale.txt",
                  "   18   -rw-r--r--   1 jpace jpace   14834 2010-12-04 15:24 17-ChaucersTaleOfSirThopas.txt",
                  "   19   -rw-r--r--   1 jpace jpace   43249 2010-12-04 15:24 18-ChaucersTaleOfMeliboeus.txt",
                  "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-TheMonksTale.txt",
                  "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPriestsTale.txt",
                  "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-TheSecondNunsTale.txt",
                  "   23   -rw-r--r--   1 jpace jpace   [30m[43m52953[0m 2010-12-04 15:24 22-TheCanonsYeomansTale.txt",
                 ]
      run_app_test expected, [ '--and=-1', '\b529\d{2}\b', 'TheKni.*Tale' ], fname
    end

    def test_multi_line_grep_one_file
      fname = to_path "textfile.txt"
      expected = [
                  "  -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                  "  -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-TheSecondNunsTale.txt",
                  "  -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-TheFranklinsTale.txt",
                 ]
      run_app_test expected, [ '-g', '--and=3', '\b5\d{4}\b', 'TheS.*Tale' ], fname
    end

    def test_multi_line_grep_two_files
      fnames = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = [
                  RES_DIR + "/textfile.txt:  -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-TheSecondNunsTale.txt",
                  RES_DIR + "/filelist.txt:21-The_Second_Nuns_Tale.txt",
                 ]
      run_app_test expected, [ '-g', '--and=3', '\b21\b', 'The.*Can.*Tale' ], *fnames
    end
  end
end

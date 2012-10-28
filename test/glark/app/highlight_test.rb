#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::HighlightTestCase < Glark::AppTestCase
  def test_line_number_highlight
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "     [36m3[0m   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[30m[43mTheMillersTale[0m.txt",
                "     [36m6[0m   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-[30m[43mTheManOfLawsTale[0m.txt",
                "    [36m11[0m   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "    [36m20[0m   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[43mTheMonksTale[0m.txt",
                "    [36m24[0m   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[30m[43mTheManciplesTale[0m.txt",
               ]
    run_app_test expected, [ '--line-number-color', 'cyan', 'TheM\w+Tale' ], fname
  end

  def test_file_names_no_highlight
    files = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [
                "[1m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[30m[43mTheMillersTale[0m.txt",
                "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-[30m[43mTheManOfLawsTale[0m.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[43mTheMonksTale[0m.txt",
                "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[30m[43mTheManciplesTale[0m.txt",
                "[1m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                "    3 02-[30m[43mThe_Millers_Tale[0m.txt",
                "    6 05-[30m[43mThe_Man_Of_Laws_Tale[0m.txt",
                "   11 10-[30m[43mThe_Merchants_Tale[0m.txt",
                "   20 19-[30m[43mThe_Monks_Tale[0m.txt",
                "   24 23-[30m[43mThe_Manciples_Tale[0m.txt",
               ]
    run_app_test expected, [ 'The.?M.*Tale' ], *files
  end

  def test_file_names_highlight
    files = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [
                "[33m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[30m[43mTheMillersTale[0m.txt",
                "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-[30m[43mTheManOfLawsTale[0m.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[43mTheMonksTale[0m.txt",
                "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[30m[43mTheManciplesTale[0m.txt",
                "[33m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                "    3 02-[30m[43mThe_Millers_Tale[0m.txt",
                "    6 05-[30m[43mThe_Man_Of_Laws_Tale[0m.txt",
                "   11 10-[30m[43mThe_Merchants_Tale[0m.txt",
                "   20 19-[30m[43mThe_Monks_Tale[0m.txt",
                "   24 23-[30m[43mThe_Manciples_Tale[0m.txt",
               ]
    run_app_test expected, [ '--file-color', 'yellow', 'The.?M.*Tale' ], *files
  end
end

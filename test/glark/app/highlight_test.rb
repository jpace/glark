#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class HighlightTestCase < AppTestCase
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

    def test_highlight_multi
      fname = '/proj/org/incava/glark/test/resources/04-TheCooksTale.txt'
      expected = [
                  "    1 Of many a p[30m[43mi[0mlgr[30m[43mi[0mm hast thou Chr[30m[43mi[0mste's curse,",
                  "    2 For of [30m[45mthy[0m parsley yet fare [30m[42mthe[0my [30m[42mthe[0m worse.",
                  "    3 ",
                  "    4 That [30m[42mthe[0my have eaten [30m[43mi[0mn [30m[45mthy[0m stubble goose:",
                  "    5 For [30m[43mi[0mn [30m[45mthy[0m shop doth many a fly go loose.",
                  "    6 ",
                  "    7 Now tell on, gentle Roger, by [30m[45mthy[0m name,",
                  "    8 But yet I pray [30m[42mthe[0me be not wroth for game;",
                  "    9 A man may say full sooth [30m[43mi[0mn game and play.",
                 ]
      run_app_test expected, [ '--and=3', 'i', '--or', 'the', 'thy' ], fname
    end

    def test_highlight_single
      fname = '/proj/org/incava/glark/test/resources/04-TheCooksTale.txt'
      expected = [
                  "    1 Of many a p[30m[43mi[0mlgr[30m[43mi[0mm hast thou Chr[30m[43mi[0mste's curse,",
                  "    2 For of [30m[43mthy[0m parsley yet fare [30m[43mthe[0my [30m[43mthe[0m worse.",
                  "    3 ",
                  "    4 That [30m[43mthe[0my have eaten [30m[43mi[0mn [30m[43mthy[0m stubble goose:",
                  "    5 For [30m[43mi[0mn [30m[43mthy[0m shop doth many a fly go loose.",
                  "    6 ",
                  "    7 Now tell on, gentle Roger, by [30m[43mthy[0m name,",
                  "    8 But yet I pray [30m[43mthe[0me be not wroth for game;",
                  "    9 A man may say full sooth [30m[43mi[0mn game and play.",
                 ]
      run_app_test expected, [ '--highlight=single', '--and=3', 'i', '--or', 'the', 'thy' ], fname
    end
  end
end

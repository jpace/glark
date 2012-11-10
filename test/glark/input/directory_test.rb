#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::DirectoryTestCase < Glark::AppTestCase
  def test_default
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [ 
                '[1m/proj/org/incava/glark/test/resources/filelist.txt[0m',
                '    9 08-[30m[43mThe_Sompnours_Tale[0m.txt',
                '   12 11-[30m[43mThe_Squires_Tale[0m.txt',
                '   16 15-[30m[43mThe_Shipmans_Tale[0m.txt',
                '   22 21-[30m[43mThe_Second_Nuns_Tale[0m.txt',
                '[1m/proj/org/incava/glark/test/resources/spaces.txt[0m',
                '    9 08 [30m[43mThe Sompnours Tale[0m.txt',
                '   12 11 [30m[43mThe Squires Tale[0m.txt',
                '   16 15 [30m[43mThe Shipmans Tale[0m.txt',
                '   22 21 [30m[43mThe Second Nuns Tale[0m.txt',
                '[1m/proj/org/incava/glark/test/resources/textfile.txt[0m',
                '    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt',
                '   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt',
                '   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt',
                '   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt',
]
    run_app_test expected, [ 'The.*S.*Tale' ], dirname
  end

  def test_list
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [ 
                '[1m/proj/org/incava/glark/test/resources/filelist.txt[0m',
                '    9 08-[30m[43mThe_Sompnours_Tale[0m.txt',
                '   12 11-[30m[43mThe_Squires_Tale[0m.txt',
                '   16 15-[30m[43mThe_Shipmans_Tale[0m.txt',
                '   22 21-[30m[43mThe_Second_Nuns_Tale[0m.txt',
                '[1m/proj/org/incava/glark/test/resources/spaces.txt[0m',
                '    9 08 [30m[43mThe Sompnours Tale[0m.txt',
                '   12 11 [30m[43mThe Squires Tale[0m.txt',
                '   16 15 [30m[43mThe Shipmans Tale[0m.txt',
                '   22 21 [30m[43mThe Second Nuns Tale[0m.txt',
                '[1m/proj/org/incava/glark/test/resources/textfile.txt[0m',
                '    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt',
                '   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt',
                '   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt',
                '   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt',
]
    run_app_test expected, [ '--directories=list', 'The.*S.*Tale' ], dirname
  end

  def test_recurse_as_option
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/canterbury/franklin/tale.txt[0m",
                "  298 For th' hori[30m[43mzon had reft the[0m sun his light",
                "[1m/proj/org/incava/glark/test/resources/canterbury/prologue.txt[0m",
                "  248 Of yeddings he bare utterly the pri[30m[43mze[0m.",
                "  253 Better than a la[30m[43mzar or a beggere[0m,",
                "  256 To have with such la[30m[43mzars acquaintance[0m.",
                "  330 Justice he was full often in assi[30m[43mze[0m,",
                "  605 Of which there was a do[30m[43mzen in that house[0m,",
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "    8 si[30m[43mze[0m-limit: 1000",
                "Binary file /proj/org/incava/glark/test/resources/textfile.txt.gz matches",
                "[1m/proj/org/incava/glark/test/resources/zfile.txt[0m",
                "    1 [30m[43mzaffre[0ms",
                "    2 [30m[43mzoae[0ma",
                "    3 [30m[43mzoae[0ma's",
                "    4 [30m[43mzoe[0ma",
                "    5 [30m[43mzoe[0mas",
                "    6 [30m[43mzonulae[0m",
                "    7 [30m[43mzooe[0ma",
                "    8 [30m[43mzooeae[0m",
                "    9 [30m[43mzooe[0mal",
                "   10 [30m[43mzooe[0mas",
                "   11 [30m[43mzooe[0mcia",
                "   12 [30m[43mzooe[0mcium",
                "   13 [30m[43mzoogloeae[0m",
                "   14 [30m[43mzoogloe[0mal",
                "   15 [30m[43mzoogloe[0mas",
                "   16 [30m[43mzygae[0mnid",
               ]
    run_app_test expected, [ '--directories=recurse', 'z.*e' ], dirname
  end

  def test_recurse_ellipses
    dirname = '/proj/org/incava/glark/test/resources/...'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                "    9 08-[30m[43mThe_Sompnours_Tale[0m.txt",
                "   12 11-[30m[43mThe_Squires_Tale[0m.txt",
                "   16 15-[30m[43mThe_Shipmans_Tale[0m.txt",
                "   22 21-[30m[43mThe_Second_Nuns_Tale[0m.txt",
                "[1m/proj/org/incava/glark/test/resources/spaces.txt[0m",
                "    9 08 [30m[43mThe Sompnours Tale[0m.txt",
                "   12 11 [30m[43mThe Squires Tale[0m.txt",
                "   16 15 [30m[43mThe Shipmans Tale[0m.txt",
                "   22 21 [30m[43mThe Second Nuns Tale[0m.txt",
                "[1m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt",
               ]
    run_app_test expected, [ 'The.?S.*Tale' ], dirname
  end

  def test_recurse_ellipses_limit
    dirname = '/proj/org/incava/glark/test/resources/...1'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                "    9 08-[30m[43mThe_Sompnours_Tale[0m.txt",
                "   12 11-[30m[43mThe_Squires_Tale[0m.txt",
                "   16 15-[30m[43mThe_Shipmans_Tale[0m.txt",
                "   22 21-[30m[43mThe_Second_Nuns_Tale[0m.txt",
                "[1m/proj/org/incava/glark/test/resources/spaces.txt[0m",
                "    9 08 [30m[43mThe Sompnours Tale[0m.txt",
                "   12 11 [30m[43mThe Squires Tale[0m.txt",
                "   16 15 [30m[43mThe Shipmans Tale[0m.txt",
                "   22 21 [30m[43mThe Second Nuns Tale[0m.txt",
                "[1m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt",
               ]
    run_app_test expected, [ 'The.?S.*Tale' ], dirname
  end

  def test_skip
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [ ]
    run_app_test expected, [ '--directories=skip', 'The.*Tale' ], dirname
  end

  def test_list_no_files_in_directory
    dirname = '/proj/org/incava/glark/test'
    expected = [ ]
    run_app_test expected, [ '--directories=list', 'The.*Tale' ], dirname
  end
end

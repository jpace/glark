#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::DirectoryTestCase < Glark::AppTestCase
  def run_directory_list_test args
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
    run_app_test expected, args + [ 'The.*S.*Tale' ], dirname
  end

  def test_default
    run_directory_list_test Array.new
  end

  def test_list
    run_directory_list_test %w{ --directories=list }
  end

  def test_recurse_as_option
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/add.rb[0m",
                "    5   def initiali[30m[43mze[0m x, y",
                "[1m/proj/org/incava/glark/test/resources/canterbury/franklin/tale.txt[0m",
                "  298 For th' hori[30m[43mzon had reft the[0m sun his light",
                "[1m/proj/org/incava/glark/test/resources/canterbury/prologue.txt[0m",
                "  248 Of yeddings he bare utterly the pri[30m[43mze[0m.",
                "  253 Better than a la[30m[43mzar or a beggere[0m,",
                "  256 To have with such la[30m[43mzars acquaintance[0m.",
                "  330 Justice he was full often in assi[30m[43mze[0m,",
                "  605 Of which there was a do[30m[43mzen in that house[0m,",
                "[1m/proj/org/incava/glark/test/resources/greet.rb[0m",
                "    8   def initiali[30m[43mze name[0m",
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "    8 si[30m[43mze[0m-limit: 1000",
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

  def run_recurse_ellipses_all_expected dirname
    expected = [
                "[1m/proj/org/incava/glark/test/resources/canterbury/franklin/prologue.txt[0m",
                "   60 Have me e[30m[43mxcused of my rude speec[0mh.",
                "[1m/proj/org/incava/glark/test/resources/canterbury/franklin/tale.txt[0m",
                "  530 Phoebus wa[30m[43mx'd old, and hued[0m like latoun,",
                "  560 Neither his collect, nor his e[30m[43mxpanse yea[0mrs,",
                "  567 From the head of that fi[30m[43mx'd Aries[0m above,",
                "  706 Why should I more e[30m[43mxamples hereo[0mf sayn?",
                "[1m/proj/org/incava/glark/test/resources/canterbury/prologue.txt[0m",
                "  187 He gave not of the te[30m[43mxt a pulled hen[0m,",
                "  192 This ilke te[30m[43mxt held he not worth an oyster[0m;",
                "  291 Betwi[30m[43mxte Middleburg and Orewel[0ml",
                "  292 Well could he in e[30m[43mxchange shieldes sel[0ml",
                "  300 A CLERK there was of O[30m[43mxen[0mford also,",
                "  327 There was also, full rich of e[30m[43mxcellen[0mce.",
                "  417 From Bourdeau[30m[43mx-ward, while that the chapmen sleep[0m;",
                "  578 His beard as any sow or fo[30m[43mx was red[0m,",
                "  604 That were of law e[30m[43mxper[0mt and curious:",
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "   10 te[30m[43mxt-color-3: underline magen[0mta",
               ]
    run_app_test expected, [ 'x.*e\w' ], dirname
  end
  
  def test_recurse_ellipses_no_limit
    dirname = '/proj/org/incava/glark/test/resources/...'
    run_recurse_ellipses_all_expected dirname
  end

  def test_recurse_ellipses_limit_zero
    dirname = '/proj/org/incava/glark/test/resources/...0'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "   10 te[30m[43mxt-color-3: underline magen[0mta",
               ]
    run_app_test expected, [ 'x.*e\w' ], dirname
  end

  def test_recurse_ellipses_limit_one
    dirname = '/proj/org/incava/glark/test/resources/...1'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/canterbury/prologue.txt[0m",
                "  187 He gave not of the te[30m[43mxt a pulled hen[0m,",
                "  192 This ilke te[30m[43mxt held he not worth an oyster[0m;",
                "  291 Betwi[30m[43mxte Middleburg and Orewel[0ml",
                "  292 Well could he in e[30m[43mxchange shieldes sel[0ml",
                "  300 A CLERK there was of O[30m[43mxen[0mford also,",
                "  327 There was also, full rich of e[30m[43mxcellen[0mce.",
                "  417 From Bourdeau[30m[43mx-ward, while that the chapmen sleep[0m;",
                "  578 His beard as any sow or fo[30m[43mx was red[0m,",
                "  604 That were of law e[30m[43mxper[0mt and curious:",
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "   10 te[30m[43mxt-color-3: underline magen[0mta",
               ]
    run_app_test expected, [ 'x.*e\w' ], dirname
  end

  def test_recurse_ellipses_limit_two
    dirname = '/proj/org/incava/glark/test/resources/...2'
    run_recurse_ellipses_all_expected dirname
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

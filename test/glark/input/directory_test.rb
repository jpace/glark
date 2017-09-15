#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class DirectoryTestCase < AppTestCase
    include Glark::Resources
    
    def run_directory_list_test args
      expected = [ 
                  "[1m" + RES_DIR + "/filelist.txt[0m",
                  "    9 08-[30m[43mThe_Sompnours_Tale[0m.txt",
                  "   12 11-[30m[43mThe_Squires_Tale[0m.txt",
                  "   16 15-[30m[43mThe_Shipmans_Tale[0m.txt",
                  "   22 21-[30m[43mThe_Second_Nuns_Tale[0m.txt",
                  "[1m" + RES_DIR + "/spaces.txt[0m",
                  "    9 08 [30m[43mThe Sompnours Tale[0m.txt",
                  "   12 11 [30m[43mThe Squires Tale[0m.txt",
                  "   16 15 [30m[43mThe Shipmans Tale[0m.txt",
                  "   22 21 [30m[43mThe Second Nuns Tale[0m.txt",
                  "[1m" + RES_DIR + "/textfile.txt[0m",
                  "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                  "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                  "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                  "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt",
                 ]
      run_app_test expected, args + [ "The.*S.*Tale" ], RES_DIR
    end

    def test_default
      run_directory_list_test Array.new
    end

    def test_list
      run_directory_list_test %w{ --directories=list }
    end

    def test_recurse_as_option
      expected = [
                  "[1m" + RES_DIR + "/add.rb[0m",
                  "    5   def initiali[30m[43mze[0m x, y",
                  "[1m" + RES_DIR + "/canterbury/franklin/tale.txt[0m",
                  "  298 For th' hori[30m[43mzon had reft the[0m sun his light",
                  "[1m" + RES_DIR + "/canterbury/prologue.txt[0m",
                  "  248 Of yeddings he bare utterly the pri[30m[43mze[0m.",
                  "  253 Better than a la[30m[43mzar or a beggere[0m,",
                  "  256 To have with such la[30m[43mzars acquaintance[0m.",
                  "  330 Justice he was full often in assi[30m[43mze[0m,",
                  "  605 Of which there was a do[30m[43mzen in that house[0m,",
                  "[1m" + RES_DIR + "/greet.rb[0m",
                  "    5   def initiali[30m[43mze name[0m",
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "    8 si[30m[43mze[0m-limit: 1000",
                  "[1m" + RES_DIR + "/zfile.txt[0m",
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
      run_app_test expected, [ '--directories=recurse', 'z.*e' ], RES_DIR
    end

    def run_recurse_ellipses_all_expected dirname
      expected = [
                  "[1m" + RES_DIR + "/canterbury/franklin/prologue.txt[0m",
                  "   60 Have me e[30m[43mxcused of my rude speec[0mh.",
                  "[1m" + RES_DIR + "/canterbury/franklin/tale.txt[0m",
                  "  530 Phoebus wa[30m[43mx'd old, and hued[0m like latoun,",
                  "  560 Neither his collect, nor his e[30m[43mxpanse yea[0mrs,",
                  "  567 From the head of that fi[30m[43mx'd Aries[0m above,",
                  "  706 Why should I more e[30m[43mxamples hereo[0mf sayn?",
                  "[1m" + RES_DIR + "/canterbury/prologue.txt[0m",
                  "  187 He gave not of the te[30m[43mxt a pulled hen[0m,",
                  "  192 This ilke te[30m[43mxt held he not worth an oyster[0m;",
                  "  291 Betwi[30m[43mxte Middleburg and Orewel[0ml",
                  "  292 Well could he in e[30m[43mxchange shieldes sel[0ml",
                  "  300 A CLERK there was of O[30m[43mxen[0mford also,",
                  "  327 There was also, full rich of e[30m[43mxcellen[0mce.",
                  "  417 From Bourdeau[30m[43mx-ward, while that the chapmen sleep[0m;",
                  "  578 His beard as any sow or fo[30m[43mx was red[0m,",
                  "  604 That were of law e[30m[43mxper[0mt and curious:",
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "   10 te[30m[43mxt-color-3: underline magen[0mta",
                 ]
      run_app_test expected, [ 'x.*e\w' ], dirname
    end
    
    def test_recurse_ellipses_no_limit
      run_recurse_ellipses_all_expected RES_DIR + "/..."
    end

    def test_recurse_ellipses_limit_zero
      expected = [
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "   10 te[30m[43mxt-color-3: underline magen[0mta",
                 ]
      run_app_test expected, [ 'x.*e\w' ], RES_DIR + "/...0"
    end

    def test_recurse_ellipses_limit_one
      expected = [
                  "[1m" + RES_DIR + "/canterbury/prologue.txt[0m",
                  "  187 He gave not of the te[30m[43mxt a pulled hen[0m,",
                  "  192 This ilke te[30m[43mxt held he not worth an oyster[0m;",
                  "  291 Betwi[30m[43mxte Middleburg and Orewel[0ml",
                  "  292 Well could he in e[30m[43mxchange shieldes sel[0ml",
                  "  300 A CLERK there was of O[30m[43mxen[0mford also,",
                  "  327 There was also, full rich of e[30m[43mxcellen[0mce.",
                  "  417 From Bourdeau[30m[43mx-ward, while that the chapmen sleep[0m;",
                  "  578 His beard as any sow or fo[30m[43mx was red[0m,",
                  "  604 That were of law e[30m[43mxper[0mt and curious:",
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "   10 te[30m[43mxt-color-3: underline magen[0mta",
                 ]
      run_app_test expected, [ 'x.*e\w' ], RES_DIR + "/...1"
    end

    def test_recurse_ellipses_limit_two
      run_recurse_ellipses_all_expected RES_DIR + "/...2"
    end

    def test_skip
      expected = [ ]
      run_app_test expected, [ '--directories=skip', 'The.*Tale' ], RES_DIR
    end

    def test_list_no_files_in_directory
      expected = [ ]
      run_app_test expected, [ '--directories=list', 'The.*Tale' ], TEST_DIR
    end

    def test_recurse_from_current_dir
      origdir = Dir.pwd
      Dir.chdir RES_DIR
      expected = [ 
                  "[1mfilelist.txt[0m",
                  "   23 22-[30m[43mThe_Canons_Yeomans_Tale[0m.txt",
                  "[1mspaces.txt[0m",
                  "   23 22 [30m[43mThe Canons Yeomans Tale[0m.txt",
                  "[1mtextfile.txt[0m",
                  "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-[30m[43mTheCanonsYeomansTale[0m.txt",
                 ]
      run_app_test expected, [ '-r', 'The.*Y.*Tale' ], '.'
      Dir.chdir origdir
    end

    def test_list_with_binaries_read_skip_unreadable
      expected = [ 
                  "[1m" + RES_DIR + "/filelist.txt[0m",
                  "   23 22-[30m[43mThe_Canons_Yeomans_Tale[0m.txt",
                  "[1m" + RES_DIR + "/spaces.txt[0m",
                  "   23 22 [30m[43mThe Canons Yeomans Tale[0m.txt",
                  "[1m" + RES_DIR + "/textfile.txt[0m",
                  "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-[30m[43mTheCanonsYeomansTale[0m.txt",
                  "[1m" + RES_DIR + "/textfile.txt.gz[0m",
                  "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-[30m[43mTheCanonsYeomansTale[0m.txt",
                  "[1mfilelist.txt (in " + RES_DIR + "/txt.tgz)[0m",
                  "   23 22-[30m[43mThe_Canons_Yeomans_Tale[0m.txt",
                 ]
      run_app_test expected, [ '-r', '--binary-files=read', 'The.*Y.*Tale' ], RES_DIR + "/..."
    end

    def test_list_with_binaries_list_skip_unreadable
      dirname = RES_DIR + "/..."
      expected = [ 
                  "[1m" + RES_DIR + "/aaa.zip[0m",
                  "    1 [30m[43mabcfile.txt[0m",
                  "[1m" + RES_DIR + "/rc.tar[0m",
                  "    1 [30m[43mrcext.txt[0m",
                  "    2 [30m[43mrcfile.txt[0m",
                  "    3 [30m[43mrcgrep.txt[0m",
                  "    4 [30m[43mrcmatch.txt[0m",
                  "    5 [30m[43mrcpath.txt[0m",
                  "[1m" + RES_DIR + "/txt.tgz[0m",
                  "    1 [30m[43mfilelist.txt[0m",
                  "    2 [30m[43mrcext.txt[0m",
                 ]
      run_app_test expected, [ '-r', '--binary-files=list', '^\w+\.txt$' ], RES_DIR
    end
  end
end

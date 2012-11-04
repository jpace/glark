#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::DirectoryTestCase < Glark::AppTestCase
  def test_read_as_default
    # I do not know what --directories=read does, and testing with grep provides
    # no answer.

    dirname = '/proj/org/incava/glark/test/resources'
    expected = [ ]
    run_app_test expected, [ 'The.*Tale' ], dirname
  end

  def test_recurse
    dirname = '/proj/org/incava/glark/test/resources'
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
    run_app_test expected, [ '--directories=recurse', 'The.?S.*Tale' ], dirname
  end

  def test_skip
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [ ]
    run_app_test expected, [ 'The.*Tale' ], dirname
  end
end

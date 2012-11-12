#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::PathTestCase < Glark::AppTestCase
  def test_with_single
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "    1 # commen[30m[43mt here[0m",
                "    2 highligh[30m[43mt: single[0m",
                "    4 local-config-files: [30m[43mtrue[0m",
                "    7 ignore-case: [30m[43mtrue[0m",
                "   10 [30m[43mtext-color-3: underline mage[0mnta",
                "[1m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-TheKnigh[30m[43mtsTale[0m.txt",
                "    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-TheWifeOfBa[30m[43mthsTale[0m.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchan[30m[43mtsTale[0m.txt",
                "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-TheDoc[30m[43mtorsTale[0m.txt",
                "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPries[30m[43mtsTale[0m.txt",
               ]
    run_app_test expected, [ '-r', '--match-path', 'test/resources/.*ile.txt$', 't.*e' ], dirname
  end

  def test_without_single
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                "    2 01-The_Knigh[30m[43mts_Tale[0m.txt",
                "    7 06-The_Wife_Of_Ba[30m[43mths_Tale[0m.txt",
                "   11 10-The_Merchan[30m[43mts_Tale[0m.txt",
                "   14 13-The_Doc[30m[43mtors_Tale[0m.txt",
                "   21 20-The_Nuns_Pries[30m[43mts_Tale[0m.txt",
                "[1m/proj/org/incava/glark/test/resources/rcgrep.txt[0m",
                "    1 grep: [30m[43mtrue[0m",
                "[1m/proj/org/incava/glark/test/resources/rcmatch.txt[0m",
                "    1 ma[30m[43mtch-name[0m: \\w+.java",
                "    2 ma[30m[43mtch-name[0m: \\w+.rb",
                "    4 no[30m[43mt-name[0m: zxcdjlk",
                "[1m/proj/org/incava/glark/test/resources/rcpath.txt[0m",
                "    2 ma[30m[43mtch-dirpath: src/te[0mst/ruby",
                "[1m/proj/org/incava/glark/test/resources/spaces.txt[0m",
                "    2 01 The Knigh[30m[43mts Tale[0m.txt",
                "    7 06 The Wife Of Ba[30m[43mths Tale[0m.txt",
                "   11 10 The Merchan[30m[43mts Tale[0m.txt",
                "   14 13 The Doc[30m[43mtors Tale[0m.txt",
                "   21 20 The Nuns Pries[30m[43mts Tale[0m.txt",
                "Binary file /proj/org/incava/glark/test/resources/textfile.txt.gz matches",
               ]
    run_app_test expected, [ '-r', '--not-path', 'test/resources/.*e.txt$', 't.*e' ], dirname
  end

  def test_with_multiple
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/canterbury/franklin/tale.txt[0m",
                "   80 That is betwi[30m[43mxt a husband and his wife[0m?",
                "[1m/proj/org/incava/glark/test/resources/canterbury/prologue.txt[0m",
                "  187 He gave not of the te[30m[43mxt a pulled he[0mn,",
                "  192 This ilke te[30m[43mxt held he not worth an oyste[0mr;",
                "  291 Betwi[30m[43mxte Middleburg and Orewe[0mll",
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "   10 te[30m[43mxt-color-3: underline mage[0mnta",
               ]
    run_app_test expected, [ '-r', '--match-path', 'test/resources/.*ile.txt$', '--match-path', 'test/resources/canterbury/.*.txt$', 'xt.*e' ], dirname
  end

  def test_without_multiple
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                "    2 01-The_Knigh[30m[43mts_Tale[0m.txt",
                "   11 10-The_Merchan[30m[43mts_Tale[0m.txt",
                "   21 20-The_Nuns_Pries[30m[43mts_Tale[0m.txt",
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "    2 highligh[30m[43mt: single[0m",
                "[1m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-TheKnigh[30m[43mtsTale[0m.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchan[30m[43mtsTale[0m.txt",
                "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPries[30m[43mtsTale[0m.txt",
               ]
    run_app_test expected, [ '-r', '--not-path', 'test/resources/\d.*e.txt$', '--not-path', 'test/resources/canterbury/.*.txt$', 't\W*s\w*e' ], dirname
  end
end

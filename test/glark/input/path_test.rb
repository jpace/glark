#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class PathTestCase < AppTestCase
    def test_match_single
      expected = [
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "    1 # commen[30m[43mt here[0m",
                  "    2 highligh[30m[43mt: single[0m",
                  "    4 local-config-files: [30m[43mtrue[0m",
                  "    7 ignore-case: [30m[43mtrue[0m",
                  "   10 [30m[43mtext-color-3: underline mage[0mnta",
                  "[1m" + RES_DIR + "/textfile.txt[0m",
                  "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-TheKnigh[30m[43mtsTale[0m.txt",
                  "    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-TheWifeOfBa[30m[43mthsTale[0m.txt",
                  "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchan[30m[43mtsTale[0m.txt",
                  "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-TheDoc[30m[43mtorsTale[0m.txt",
                  "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPries[30m[43mtsTale[0m.txt",
                 ]
      run_app_test expected, [ '-r', '--match-path', 'test/resources/.*ile.txt$', 't.*e' ], RES_DIR
    end

    def test_not_single
      expected = [
                  "[1m" + RES_DIR + "/filelist.txt[0m",
                  "    2 01-The_Kni[30m[43mghts_Tale[0m.txt",
                  "[1m" + RES_DIR + "/rcgrep.txt[0m",
                  "    1 [30m[43mgrep: true[0m",
                  "[1m" + RES_DIR + "/spaces.txt[0m",
                  "    2 01 The Kni[30m[43mghts Tale[0m.txt",
                 ]
      run_app_test expected, [ '-r', '--skip-path', 'test/resources/.*e.txt$', 'g.*t.*e\b' ], RES_DIR
    end

    def test_match_multiple
      expected = [
                  "[1m" + RES_DIR + "/canterbury/franklin/tale.txt[0m",
                  "   80 That is betwi[30m[43mxt a husband and his wife[0m?",
                  "[1m" + RES_DIR + "/canterbury/prologue.txt[0m",
                  "  187 He gave not of the te[30m[43mxt a pulled he[0mn,",
                  "  192 This ilke te[30m[43mxt held he not worth an oyste[0mr;",
                  "  291 Betwi[30m[43mxte Middleburg and Orewe[0mll",
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "   10 te[30m[43mxt-color-3: underline mage[0mnta",
                 ]
      run_app_test expected, [ '-r', '--match-path', 'test/resources/.*ile.txt$', '--match-path', 'test/resources/canterbury/.*.txt$', 'xt.*e' ], RES_DIR
    end

    def test_not_multiple
      expected = [
                  "[1m" + RES_DIR + "/filelist.txt[0m",
                  "    2 01-The_Knigh[30m[43mts_Tale[0m.txt",
                  "   11 10-The_Merchan[30m[43mts_Tale[0m.txt",
                  "   21 20-The_Nuns_Pries[30m[43mts_Tale[0m.txt",
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "    2 highligh[30m[43mt: single[0m",
                  "[1m" + RES_DIR + "/textfile.txt[0m",
                  "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-TheKnigh[30m[43mtsTale[0m.txt",
                  "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchan[30m[43mtsTale[0m.txt",
                  "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPries[30m[43mtsTale[0m.txt",
                 ]
      run_app_test expected, [ '-r', '--skip-path', 'test/resources/\d.*e.txt$', '--skip-path', 'test/resources/canterbury/.*.txt$', 't\W*s\w*e' ], RES_DIR
    end
  end
end

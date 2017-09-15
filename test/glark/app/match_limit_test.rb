#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class MatchLimitTestCase < AppTestCase
    def test_one_file_limit_one
      fname = to_path "textfile.txt"
      expected = [
                  "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                 ]
      run_app_test expected, [ '-m', '1', 'TheS\w+Tale' ], fname
    end

    def test_one_file_limit_two
      fname = to_path "textfile.txt"
      expected = [
                  "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                  "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                 ]
      run_app_test expected, [ '-m', '2', 'TheS\w+Tale' ], fname
    end

    def test_two_files_limit_one
      fnames = [ to_path("textfile.txt"), to_path("spaces.txt") ]
      expected = [
                  "[1m" + RES_DIR + "/textfile.txt[0m",
                  "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                  "[1m" + RES_DIR + "/spaces.txt[0m",
                  "    9 08 [30m[43mThe Sompnours Tale[0m.txt",
                 ]
      run_app_test expected, [ '-m', '1', 'The.?S.*Tale' ], *fnames
    end

    def test_two_files_limit_two
      fnames = [ to_path("textfile.txt"), to_path("spaces.txt") ]
      expected = [
                  "[1m" + RES_DIR + "/textfile.txt[0m",
                  "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                  "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                  "[1m" + RES_DIR + "/spaces.txt[0m",
                  "    9 08 [30m[43mThe Sompnours Tale[0m.txt",
                  "   12 11 [30m[43mThe Squires Tale[0m.txt",
                 ]
      run_app_test expected, [ '-m', '2', 'The.?S.*Tale' ], *fnames
    end
  end
end

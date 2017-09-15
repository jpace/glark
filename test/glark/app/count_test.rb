#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class CountTestCase < AppTestCase
    include Glark::Resources
    
    def test_one_file
      fname = to_path "spaces.txt"
      expected = [
        "    13",
      ]
      run_app_test expected, [ '--count', '\wa\w+s' ], fname
    end

    def test_two_files_one_matches
      fnames = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = [
        "[1m" + RES_DIR + "/textfile.txt[0m",
        "    2",
      ]
      run_app_test expected, [ '--count', '2 ' ], *fnames
    end

    def test_two_files_both_match
      fnames = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = [
        "[1m" + RES_DIR + "/textfile.txt[0m",
        "    13",
        "[1m" + RES_DIR + "/filelist.txt[0m",
        "    2",
      ]
      run_app_test expected, [ '--count', '6.*The' ], *fnames
    end

    def test_grep_one_file
      fnames = [ to_path("spaces.txt") ]
      expected = [
        "2",
      ]
      run_app_test expected, [ '-g', '--count', '6.*The' ], *fnames
    end

    def test_grep_two_files_one_matches
      fnames = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = [
        RES_DIR + "/textfile.txt:2",
      ]
      run_app_test expected, [ '-g', '--count', '2 ' ], *fnames
    end

    def test_grep_two_files_both_match
      fnames = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = [
        RES_DIR + "/textfile.txt:13",
        RES_DIR + "/filelist.txt:2"
      ]
      run_app_test expected, [ '-g', '--count', '6.*The' ], *fnames
    end

    def test_grep_one_file_invert
      fnames = [ to_path("spaces.txt") ]
      expected = [
        "24",
      ]
      run_app_test expected, [ '--invert-match', '-g', '--count', '6.*The' ], *fnames
    end

    def test_grep_two_files_invert_one_matches
      fnames = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = [
        RES_DIR + "/textfile.txt:24",
        RES_DIR + "/filelist.txt:26",
      ]
      run_app_test expected, [ '--invert-match', '-g', '--count', '2 ' ], *fnames
    end

    def test_glark_two_files_invert_both_match
      fnames = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = [
        "[1m" + RES_DIR + "/textfile.txt[0m",
        "    13",
        "[1m" + RES_DIR + "/filelist.txt[0m",
        "    24",
      ]
      run_app_test expected, [ '--invert-match', '--count', '6.*The' ], *fnames
    end
  end
end

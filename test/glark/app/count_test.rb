#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::CountTestCase < Glark::AppTestCase
  def test_one_file
    fname = '/proj/org/incava/glark/test/resources/spaces.txt'
    expected = [
                "    13",
               ]
    run_app_test expected, [ '--count', '\wa\w+s' ], fname
  end

  def test_two_files_one_matches
    fnames = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [
                "[1m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    2",
               ]
    run_app_test expected, [ '--count', '2 ' ], *fnames
  end

  def test_two_files_both_match
    fnames = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [
                "[1m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    13",
                "[1m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                "    2",
               ]
    run_app_test expected, [ '--count', '6.*The' ], *fnames
  end

  def test_grep_one_file
    fnames = [ '/proj/org/incava/glark/test/resources/spaces.txt' ]
    expected = [
                "2",
               ]
    run_app_test expected, [ '-g', '--count', '6.*The' ], *fnames
  end

  def test_grep_two_files_one_matches
    fnames = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [
                "/proj/org/incava/glark/test/resources/textfile.txt:2",
               ]
    run_app_test expected, [ '-g', '--count', '2 ' ], *fnames
  end

  def test_grep_two_files_both_match
    fnames = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [
                "/proj/org/incava/glark/test/resources/textfile.txt:13",
                "/proj/org/incava/glark/test/resources/filelist.txt:2"
               ]
    run_app_test expected, [ '-g', '--count', '6.*The' ], *fnames
  end

  def test_grep_one_file_invert
    fnames = [ '/proj/org/incava/glark/test/resources/spaces.txt' ]
    expected = [
                "24",
               ]
    run_app_test expected, [ '--invert-match', '-g', '--count', '6.*The' ], *fnames
  end

  def test_grep_two_files_invert_one_matches
    fnames = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [
                "/proj/org/incava/glark/test/resources/textfile.txt:24",
                "/proj/org/incava/glark/test/resources/filelist.txt:26",
               ]
    run_app_test expected, [ '--invert-match', '-g', '--count', '2 ' ], *fnames
  end

  def test_glark_two_files_invert_both_match
    fnames = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [
                "[1m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    13",
                "[1m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                "    24",
               ]
    run_app_test expected, [ '--invert-match', '--count', '6.*The' ], *fnames
  end
end

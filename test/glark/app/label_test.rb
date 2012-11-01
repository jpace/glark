#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::LabelTestCase < Glark::AppTestCase
  def test_one_file
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "[1mTheFileName[0m",
                "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoc[0mtorsTale.txt"
               ]
    run_app_test expected, %w{ --label TheFileName TheDoc }, fname
  end

  def test_two_files
    fnames = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/spaces.txt' ]
    expected = [
                "[1mTheFileName[0m",
                "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoc[0mtorsTale.txt",
                "[1mTheFileName[0m",
                "   14 13 [30m[43mThe Doc[0mtors Tale.txt",
               ]
    run_app_test expected, %w{ --label TheFileName The.*Doc }, *fnames
  end
end

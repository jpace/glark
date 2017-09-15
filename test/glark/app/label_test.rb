#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class LabelTestCase < AppTestCase
    def test_one_file
      fname = to_path "textfile.txt"
      expected = [
                  "[1mTheFileName[0m",
                  "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoc[0mtorsTale.txt"
                 ]
      run_app_test expected, %w{ --label TheFileName TheDoc }, fname
    end

    def test_two_files
      fnames = [ to_path("textfile.txt"), to_path("spaces.txt") ]
      expected = [
                  "[1mTheFileName[0m",
                  "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoc[0mtorsTale.txt",
                  "[1mTheFileName[0m",
                  "   14 13 [30m[43mThe Doc[0mtors Tale.txt",
                 ]
      run_app_test expected, %w{ --label TheFileName The.*Doc }, *fnames
    end
  end
end

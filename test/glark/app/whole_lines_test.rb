#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class WholeLinesTestCase < AppTestCase
    def test_
      fname = '/proj/org/incava/glark/test/resources/filelist.txt'
      expected = [
                  "   12 [30m[43m11-The_Squires_Tale.txt[0m",
                  "   16 [30m[43m15-The_Shipmans_Tale.txt[0m",
                 ]
      run_app_test expected, [ '--line-regexp', '1.*The_S\w+.txt' ], fname
    end
  end
end

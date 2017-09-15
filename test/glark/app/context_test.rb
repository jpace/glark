#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class ContextTestCase < AppTestCase
    include Glark::Resources
    
    def test_context
      fname = to_path "textfile.txt"
      expected = [
                  "   11 -   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchantsTale.txt",
                  "   12 -   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                  "   13 -   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-TheFranklinsTale.txt",
                  "   14 :   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoc[0mtorsTale.txt",
                  "   15 +   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-ThePardonersTale.txt",
                  "   16 +   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-TheShipmansTale.txt",
                  "   17 +   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-ThePrioresssTale.txt",
                 ]
      run_app_test expected, %w{ -3 TheDoc }, fname
    end

    def test_after
      fname = to_path "textfile.txt"
      expected = [
                  "   14 :   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoc[0mtorsTale.txt",
                  "   15 +   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-ThePardonersTale.txt",
                  "   16 +   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-TheShipmansTale.txt",
                 ]
      run_app_test expected, %w{ --after-context 2 TheDoc }, fname
    end

    def test_before
      fname = to_path "textfile.txt"
      expected = [
                  "   11 -   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchantsTale.txt",
                  "   12 -   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                  "   13 -   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-TheFranklinsTale.txt",
                  "   14 :   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoc[0mtorsTale.txt",
                 ]
      run_app_test expected, %w{ --before-context 3 TheDoc }, fname
    end
  end
end

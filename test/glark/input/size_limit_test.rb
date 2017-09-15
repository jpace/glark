#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class SizeLimitTestCase < AppTestCase
    include Glark::Resources
    
    def test_limit_300
      expected = [
                  "[1m" + RES_DIR + "/add.rb[0m",
                  "    4 c[30m[43mlass Adde[0mr",
                  "    5   def initia[30m[43mlize[0m x, y",
                  "[1m" + RES_DIR + "/expressions.txt[0m",
                  "    2 TheM.*Ta[30m[43mle[0m",
                  "[1m" + RES_DIR + "/greet.rb[0m",
                  "    4 c[30m[43mlass Gree[0mt",
                  "    5   def initia[30m[43mlize name[0m",
                  "    6     puts \"he[30m[43mllo, \" + name[0m",
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "    2 high[30m[43mlight: single[0m",
                  "    4 [30m[43mlocal-config-files: true[0m",
                  "    6 [30m[43mline-number-color: bold re[0md",
                  "   10 text-co[30m[43mlor-3: underline mage[0mnta",
                  "[1m" + RES_DIR + "/zfile.txt[0m",
                  "    6 zonu[30m[43mlae[0m",
                  "   13 zoog[30m[43mloeae[0m",
                  "   14 zoog[30m[43mloe[0mal",
                  "   15 zoog[30m[43mloe[0mas",
                 ]
      run_app_test expected, [ '-r', '--size-limit', '300', 'l.*e' ], RES_DIR
    end

    def test_limit_100
      expected = [
                  "[1m" + RES_DIR + "/rcext.txt[0m",
                  "    1 ma[30m[43mtch-e[0mxt: rb",
                  "    2 ma[30m[43mtch-e[0mxt: pl",
                  "[1m" + RES_DIR + "/rcgrep.txt[0m",
                  "    1 grep: [30m[43mtrue[0m",
                  "[1m" + RES_DIR + "/rcmatch.txt[0m",
                  "    1 ma[30m[43mtch-name[0m: \\w+.java",
                  "    2 ma[30m[43mtch-name[0m: \\w+.rb",
                  "[1m" + RES_DIR + "/rcpath.txt[0m",
                  "    2 ma[30m[43mtch-dirpath: src/te[0mst/ruby",
                 ]
      run_app_test expected, [ '-r', '--size-limit', '100', 't.*e' ], RES_DIR
    end
  end
end

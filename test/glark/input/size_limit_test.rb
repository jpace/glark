#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::SizeLimitTestCase < Glark::AppTestCase
  def test_limit_300
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/expressions.txt[0m",
                "    2 TheM.*Ta[30m[43mle[0m",
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "    2 high[30m[43mlight: single[0m",
                "    4 [30m[43mlocal-config-files: true[0m",
                "    6 [30m[43mline-number-color: bold re[0md",
                "   10 text-co[30m[43mlor-3: underline mage[0mnta",
                "[1m/proj/org/incava/glark/test/resources/zfile.txt[0m",
                "    6 zonu[30m[43mlae[0m",
                "   13 zoog[30m[43mloeae[0m",
                "   14 zoog[30m[43mloe[0mal",
                "   15 zoog[30m[43mloe[0mas",
               ]
    run_app_test expected, [ '-r', '--size-limit', '300', 'l.*e' ], dirname
  end

  def test_limit_100
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/rcgrep.txt[0m",
                "    1 grep: [30m[43mtrue[0m",
                "[1m/proj/org/incava/glark/test/resources/rcmatch.txt[0m",
                "    1 ma[30m[43mtch-name[0m: \\w+.java",
                "    2 ma[30m[43mtch-name[0m: \\w+.rb",
                "    4 no[30m[43mt-name[0m: zxcdjlk",
                "[1m/proj/org/incava/glark/test/resources/rcpath.txt[0m",
                "    2 ma[30m[43mtch-dirpath: src/te[0mst/ruby",
               ]
    run_app_test expected, [ '-r', '--size-limit', '100', 't.*e' ], dirname
  end
end

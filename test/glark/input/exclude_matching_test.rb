#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::ExcludeMatchingTestCase < Glark::AppTestCase
  def test_simple
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "   10 [30m[43mtext[0m-color-3: underline magenta",
               ]
    run_app_test expected, [ '-r', '--exclude-matching', 'text' ], dirname
  end
end

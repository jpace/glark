#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class ExcludeMatchingTestCase < AppTestCase
    def test_simple
      dirname = '/proj/org/incava/glark/test/resources'
      expected = [
                  "[1m/proj/org/incava/glark/test/resources/canterbury/prologue.txt[0m",
                  "  187 He gave not of the [30m[43mtext[0m a pulled hen,",
                  "  192 This ilke [30m[43mtext[0m held he not worth an oyster;",
                  "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                  "   10 [30m[43mtext[0m-color-3: underline magenta",
                 ]
      run_app_test expected, [ '-r', '--exclude-matching', 'text' ], dirname
    end
  end
end

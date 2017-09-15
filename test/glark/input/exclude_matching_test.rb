#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class ExcludeMatchingTestCase < AppTestCase
    include Glark::Resources
    
    def test_simple
      expected = [
                  "[1m" + RES_DIR + "/canterbury/prologue.txt[0m",
                  "  187 He gave not of the [30m[43mtext[0m a pulled hen,",
                  "  192 This ilke [30m[43mtext[0m held he not worth an oyster;",
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "   10 [30m[43mtext[0m-color-3: underline magenta",
                 ]
      run_app_test expected, [ '-r', '--exclude-matching', 'text' ], RES_DIR
    end
  end
end

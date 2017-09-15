#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class IgnoreCaseTestCase < AppTestCase
    include Glark::Resources
    
    def test_simple
      fname = to_path "spaces.txt"
      expected = [
                  "    6 05 [30m[43mThe Man[0m Of Laws Tale.txt",
                  "    9 08 [30m[43mThe Sompn[0mours Tale.txt",
                  "   11 10 [30m[43mThe Merchan[0mts Tale.txt",
                  "   16 15 [30m[43mThe Shipman[0ms Tale.txt",
                  "   20 19 [30m[43mThe Mon[0mks Tale.txt",
                  "   23 22 [30m[43mThe Canons Yeoman[0ms Tale.txt",
                  "   24 23 [30m[43mThe Man[0mciples Tale.txt",
                 ]
      run_app_test expected, [ '-i', 'the.*m.*n' ], fname
    end
  end
end

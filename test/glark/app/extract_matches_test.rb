#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class ExtractMatchesTestCase < AppTestCase
    include Glark::Resources
    
    def test_simple
      fname = to_path "textfile.txt"
      expected = [
                  "    1 [30m[43mThePrologue[0m",
                  "    3 [30m[43mTheMillersTale[0m",
                  "    5 [30m[43mTheCooksTale[0m",
                  "    6 [30m[43mTheManOfLawsTale[0m",
                  "   10 [30m[43mTheClerksTale[0m",
                  "   11 [30m[43mTheMerchantsTale[0m",
                  "   15 [30m[43mThePardonersTale[0m",
                  "   17 [30m[43mThePrioresssTale[0m",
                  "   20 [30m[43mTheMonksTale[0m",
                  "   23 [30m[43mTheCanonsYeomansTale[0m",
                  "   24 [30m[43mTheManciplesTale[0m",
                  "   25 [30m[43mTheParsonsTale[0m",
                 ]
      run_app_test expected, %w{ --extract-matches The[MCP]\w+ }, fname
    end
  end
end

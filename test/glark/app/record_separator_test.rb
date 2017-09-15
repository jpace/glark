#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class RecordSeparatorTestCase < AppTestCase
    def test_default
      fname = to_path "04-TheCooksTale.txt"
      expected = [
                  "    2 For of [30m[43mthy parsley yet fare they the[0m worse.",
                 ]
      run_app_test expected, [ 'thy.*the' ], fname
    end

    def test_paragraph
      fname = to_path "04-TheCooksTale.txt"
      expected = [
                  "    1 Of many a pilgrim hast thou Christe's curse,",
                  "    2 For of [30m[43mthy[0m parsley yet fare [30m[42mthe[0my [30m[42mthe[0m worse.",
                  "    3 ",
                  "    4 That [30m[42mthe[0my have eaten in [30m[43mthy[0m stubble goose:",
                  "    5 For in [30m[43mthy[0m shop doth many a fly go loose.",
                  "    6 ",
                  "    7 Now tell on, gentle Roger, by [30m[43mthy[0m name,",
                  "    8 But yet I pray [30m[42mthe[0me be not wroth for game;",
                  "    9 A man may say full sooth in game and play.",
                 ]
      run_app_test expected, [ '-0', '--and=2', 'thy', 'the' ], fname
    end
  end
end

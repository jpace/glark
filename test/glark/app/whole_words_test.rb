#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class WholeWordsTestCase < AppTestCase
    def test_no
      fname = to_path "spaces.txt"
      expected = [
                  "    6 05 The Man Of [30m[43mLaws[0m Tale.txt",
                  "    7 06 The Wife Of [30m[43mBaths[0m Tale.txt",
                  "    8 07 The Fr[30m[43miars[0m Tale.txt",
                  "   11 10 The Merc[30m[43mhants[0m Tale.txt",
                  "   13 12 The F[30m[43mranklins[0m Tale.txt",
                  "   15 14 The [30m[43mPardoners[0m Tale.txt",
                  "   16 15 The Ship[30m[43mmans[0m Tale.txt",
                  "   18 17 C[30m[43mhaucers[0m Tale Of Sir Thopas.txt",
                  "   19 18 C[30m[43mhaucers[0m Tale Of Meliboeus.txt",
                  "   23 22 The [30m[43mCanons[0m Yeo[30m[43mmans[0m Tale.txt",
                  "   24 23 The [30m[43mManciples[0m Tale.txt",
                  "   25 24 The [30m[43mParsons[0m Tale.txt",
                  "   26 25 Preces De C[30m[43mhauceres[0m.txt",
                 ]
      run_app_test expected, [ '\wa\w+s' ], fname
    end

    def test_yes
      fname = to_path "spaces.txt"
      expected = [
                  "    6 05 The Man Of [30m[43mLaws[0m Tale.txt",
                  "    7 06 The Wife Of [30m[43mBaths[0m Tale.txt",
                  "   15 14 The [30m[43mPardoners[0m Tale.txt",
                  "   23 22 The [30m[43mCanons[0m Yeomans Tale.txt",
                  "   24 23 The [30m[43mManciples[0m Tale.txt",
                  "   25 24 The [30m[43mParsons[0m Tale.txt",
                 ]
      run_app_test expected, [ '-w', '\wa\w+s' ], fname
    end
  end
end


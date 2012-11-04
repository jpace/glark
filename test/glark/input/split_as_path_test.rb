#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::SplitAsPathTestCase < Glark::AppTestCase
  def test_with
    path = '/proj/org/incava/glark/test/resources:/var/this/doesnt/exist'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/04-TheCooksTale.txt[0m",
                "    2 For of [30m[43mthy parsley yet fare they[0m the worse.",
                "    4 Tha[30m[43mt they have eaten[0m in thy stubble goose:",
                "    7 Now [30m[43mtell on, gentle Roger[0m, by thy name,",
                "    8 Bu[30m[43mt yet I pray thee[0m be not wroth for game;",
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "    1 # commen[30m[43mt her[0me",
                "   10 [30m[43mtext-color-3: underline magen[0mta",
                "Binary file /proj/org/incava/glark/test/resources/textfile.txt.gz matches",
               ]
    run_app_test expected, [ '-r', '--split-as-path', 't.*e\w' ], path
  end
end

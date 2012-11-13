#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::SplitAsPathTestCase < Glark::AppTestCase
  def test_with
    path = '/proj/org/incava/glark/test/resources:/var/this/doesnt/exist'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/canterbury/franklin/tale.txt[0m",
                "  706 Why should I more e[30m[43mxamples here[0mof sayn?",
                "[1m/proj/org/incava/glark/test/resources/canterbury/prologue.txt[0m",
                "  604 That were of law e[30m[43mxpert[0m and curious:",
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "   10 te[30m[43mxt-color-3: underl[0mine magenta",
               ]
    run_app_test expected, [ '-r', 'x.*er\w' ], path
  end

  def test_without
    path = '/proj/org/incava/glark/test/resources:/var/this/doesnt/exist'
    expected = [
               ]
    run_app_test expected, [ '-r', '--no-split-as-path', 't.*e\w' ], path
  end
end

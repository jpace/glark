#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::SplitAsPathTestCase < Glark::AppTestCase
  EXPECTED_MATCH = [
                    "[1m/proj/org/incava/glark/test/resources/canterbury/franklin/prologue.txt[0m",
                    "   60 Have me e[30m[43mxcused of my rude speec[0mh.",
                    "[1m/proj/org/incava/glark/test/resources/canterbury/franklin/tale.txt[0m",
                    "  530 Phoebus wa[30m[43mx'd old, and hued[0m like latoun,",
                    "  560 Neither his collect, nor his e[30m[43mxpanse yea[0mrs,",
                    "  567 From the head of that fi[30m[43mx'd Aries[0m above,",
                    "  706 Why should I more e[30m[43mxamples hereo[0mf sayn?",
                    "[1m/proj/org/incava/glark/test/resources/canterbury/prologue.txt[0m",
                    "  187 He gave not of the te[30m[43mxt a pulled hen[0m,",
                    "  192 This ilke te[30m[43mxt held he not worth an oyster[0m;",
                    "  291 Betwi[30m[43mxte Middleburg and Orewel[0ml",
                    "  292 Well could he in e[30m[43mxchange shieldes sel[0ml",
                    "  300 A CLERK there was of O[30m[43mxen[0mford also,",
                    "  327 There was also, full rich of e[30m[43mxcellen[0mce.",
                    "  417 From Bourdeau[30m[43mx-ward, while that the chapmen sleep[0m;",
                    "  578 His beard as any sow or fo[30m[43mx was red[0m,",
                    "  604 That were of law e[30m[43mxper[0mt and curious:",
                    "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                    "   10 te[30m[43mxt-color-3: underline magen[0mta",
                   ]
  
  def test_with
    path = '/proj/org/incava/glark/test/resources:/var/this/doesnt/exist'
    run_app_test EXPECTED_MATCH, [ '-r', 'x.*e\w' ], path
  end

  def test_with_default_list
    path = '/proj/org/incava/glark/test/resources:/var/this/doesnt/exist'
    run_app_test EXPECTED_MATCH, [ '-r', 'x.*e\w' ], path
  end

  def test_without
    path = '/proj/org/incava/glark/test/resources:/var/this/doesnt/exist'
    expected = [
               ]
    run_app_test expected, [ '-r', '--no-split-as-path', 't.*e\w' ], path
  end
end

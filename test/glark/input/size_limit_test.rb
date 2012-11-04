#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::SizeLimitTestCase < Glark::AppTestCase
  def test_limit_300
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/expressions.txt[0m",
                "    2 Th[30m[43me[0mM.*Tal[30m[43me[0m",
                "[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m",
                "    1 # comm[30m[43me[0mnt h[30m[43me[0mr[30m[43me[0m",
                "    2 highlight: singl[30m[43me[0m",
                "    4 local-config-fil[30m[43me[0ms: tru[30m[43me[0m",
                "    6 lin[30m[43me[0m-numb[30m[43me[0mr-color: bold r[30m[43me[0md",
                "    7 ignor[30m[43me[0m-cas[30m[43me[0m: tru[30m[43me[0m",
                "    8 siz[30m[43me[0m-limit: 1000",
                "   10 t[30m[43me[0mxt-color-3: und[30m[43me[0mrlin[30m[43me[0m mag[30m[43me[0mnta",
                "[1m/proj/org/incava/glark/test/resources/rcgrep.txt[0m",
                "    1 gr[30m[43me[0mp: tru[30m[43me[0m",
                "[1m/proj/org/incava/glark/test/resources/zfile.txt[0m",
                "    1 zaffr[30m[43me[0ms",
                "    2 zoa[30m[43me[0ma",
                "    3 zoa[30m[43me[0ma's",
                "    4 zo[30m[43me[0ma",
                "    5 zo[30m[43me[0mas",
                "    6 zonula[30m[43me[0m",
                "    7 zoo[30m[43me[0ma",
                "    8 zoo[30m[43me[0ma[30m[43me[0m",
                "    9 zoo[30m[43me[0mal",
                "   10 zoo[30m[43me[0mas",
                "   11 zoo[30m[43me[0mcia",
                "   12 zoo[30m[43me[0mcium",
                "   13 zooglo[30m[43me[0ma[30m[43me[0m",
                "   14 zooglo[30m[43me[0mal",
                "   15 zooglo[30m[43me[0mas",
                "   16 zyga[30m[43me[0mnid",
               ]
    run_app_test expected, [ '-r', '--size-limit', '300', 'e' ], dirname
  end

  def test_limit_100
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/expressions.txt[0m",
                "    2 Th[30m[43me[0mM.*Tal[30m[43me[0m",
                "[1m/proj/org/incava/glark/test/resources/rcgrep.txt[0m",
                "    1 gr[30m[43me[0mp: tru[30m[43me[0m",
               ]
    run_app_test expected, [ '-r', '--size-limit', '100', 'e' ], dirname
  end
end

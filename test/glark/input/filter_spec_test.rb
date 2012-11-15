#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::FilterSpecTestCase < Glark::AppTestCase
  def xxxtest_match_name_match_ext
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                '[1m/proj/org/incava/glark/test/resources/rcfile.txt[0m',
                '    1 # commen[30m[43mt here[0m',
                '    2 highligh[30m[43mt: single[0m',
                '    4 local-config-files: [30m[43mtrue[0m',
                '    7 ignore-case: [30m[43mtrue[0m',
                '   10 [30m[43mtext-color-3: underline mage[0mnta',
                '[1m/proj/org/incava/glark/test/resources/textfile.txt[0m',
                '    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-TheKnigh[30m[43mtsTale[0m.txt',
                '    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-TheWifeOfBa[30m[43mthsTale[0m.txt',
                '   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchan[30m[43mtsTale[0m.txt',
                '   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-TheDoc[30m[43mtorsTale[0m.txt',
                '   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPries[30m[43mtsTale[0m.txt',
               ]
    run_app_test expected, [ '-r', '--match-name', 'a', '--match-ext', 'rb', 't.*e' ], dirname
  end
end

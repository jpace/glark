#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class CompoundTestCase < AppTestCase
    include Glark::Resources
    
    def test_hardly_simple
      fname = to_path "textfile.txt"
      expected = [
                  "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[33m[40mTheMillersTale[0m.txt",
                  "    4   -rw-r--r--   1 jpace jpace   29296 2010-12-04 15:24 03-TheReevesTale.txt",
                  "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-TheCooksTale.txt",
                  "    6   -rw-r--r--   1 jpace jpace   [30m[43m63290[0m 2010-12-04 15:24 05-[33m[40mTheManOfLawsTale[0m.txt",
                  "    7   -rw-r--r--   1 jpace jpace   [30m[42m71054[0m 2010-12-04 15:24 06-TheWifeOfBathsTale.txt",
                  "    8   -rw-r--r--   1 jpace jpace   [30m[42m22754[0m 2010-12-04 15:24 07-[30m[45mTheFriarsTale.txt[0m",
                  "    9   -rw-r--r--   1 jpace jpace   [30m[42m35994[0m 2010-12-04 15:24 08-TheSompnoursTale.txt",
                  "   10   -rw-r--r--   1 jpace jpace   [30m[43m64791[0m 2010-12-04 15:24 09-TheClerksTale.txt",
                  "   11   -rw-r--r--   1 jpace jpace   [30m[43m65852[0m 2010-12-04 15:24 10-[33m[40mTheMerchantsTale[0m.txt",
                  "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                  "   13   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-[30m[45mTheFranklinsTale.txt[0m",
                  "   18   -rw-r--r--   1 jpace jpace   [30m[42m14834[0m 2010-12-04 15:24 17-ChaucersTaleOfSirThopas.txt",
                  "   19   -rw-r--r--   1 jpace jpace   43249 2010-12-04 15:24 18-ChaucersTaleOfMeliboeus.txt",
                  "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[33m[40mTheMonksTale[0m.txt",
                  "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPriestsTale.txt",
                  "   22   -rw-r--r--   1 jpace jpace   [30m[42m30734[0m 2010-12-04 15:24 21-TheSecondNunsTale.txt",
                  "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-TheCanonsYeomansTale.txt",
                  "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[33m[40mTheManciplesTale[0m.txt",
                 ]
      run_app_test expected, [ '--and=3', '--or', '\b6\d{4}\b', '\b\d{4}4\b', '--or', 'TheF.*', 'TheM.*Tale' ], fname
    end
  end
end

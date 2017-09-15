#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class InvertTestCase < AppTestCase
    
    def test_simple
      fname = to_path "textfile.txt"
      expected = [
                  "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-TheKnightsTale.txt",
                  "    4   -rw-r--r--   1 jpace jpace   29296 2010-12-04 15:24 03-TheReevesTale.txt",
                  "    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-TheWifeOfBathsTale.txt",
                  "    8   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-TheFriarsTale.txt",
                  "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-TheSompnoursTale.txt",
                  "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                  "   13   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-TheFranklinsTale.txt",
                  "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-TheDoctorsTale.txt",
                  "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-TheShipmansTale.txt",
                  "   18   -rw-r--r--   1 jpace jpace   14834 2010-12-04 15:24 17-ChaucersTaleOfSirThopas.txt",
                  "   19   -rw-r--r--   1 jpace jpace   43249 2010-12-04 15:24 18-ChaucersTaleOfMeliboeus.txt",
                  "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-TheSecondNunsTale.txt",
                  "   26   -rw-r--r--   1 jpace jpace    3650 2010-12-04 15:24 25-PrecesDeChauceres.txt",
                 ]
      run_app_test expected, %w{ --invert-match The.*[MCP] }, fname
    end

    def test_compound_expression
      fname = to_path "textfile.txt"
      expected = [
                  "    1   -rw-r--r--   1 jpace jpace   [30m[43m52183[0m 2010-12-04 15:24 00-ThePrologue.txt",
                  "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-TheKnightsTale.txt",
                  "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-TheMillersTale.txt",
                  "    4   -rw-r--r--   1 jpace jpace   29296 2010-12-04 15:24 03-TheReevesTale.txt",
                  "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-TheCooksTale.txt",
                  "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-TheManOfLawsTale.txt",
                  "    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-TheWifeOfBathsTale.txt",
                  "    8   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-TheFriarsTale.txt",
                  "   17   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-ThePrioresssTale.txt",
                  "   18   -rw-r--r--   1 jpace jpace   14834 2010-12-04 15:24 17-ChaucersTaleOfSirThopas.txt",
                  "   19   -rw-r--r--   1 jpace jpace   43249 2010-12-04 15:24 18-ChaucersTaleOfMeliboeus.txt",
                  "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-TheMonksTale.txt",
                  "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPriestsTale.txt",
                  "   26   -rw-r--r--   1 jpace jpace    3650 2010-12-04 15:24 25-PrecesDeChauceres.txt",
                 ]
      run_app_test expected, [ '--invert-match', '--and=6', '\b5\d{4}\b', 'TheS.*Tale' ], fname
    end
  end
end

#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::FilterTestCase < Glark::AppTestCase
  def test_one_file_with_matches
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "    1   -rw-r--r--   1 jpace jpace   52183 2010-12-04 15:24 00-ThePrologue.txt",
                "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-TheKnightsTale.txt",
                "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-TheMillersTale.txt",
                "    4   -rw-r--r--   1 jpace jpace   29296 2010-12-04 15:24 03-TheReevesTale.txt",
                "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-TheCooksTale.txt",
                "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-TheManOfLawsTale.txt",
                "    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-TheWifeOfBathsTale.txt",
                "    8   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-TheFriarsTale.txt",
                "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-TheClerksTale.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchantsTale.txt",
                "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "   13   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-TheFranklinsTale.txt",
                "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-TheDoctorsTale.txt",
                "   15   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-ThePardonersTale.txt",
                "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                "   17   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-ThePrioresssTale.txt",
                "   18   -rw-r--r--   1 jpace jpace   14834 2010-12-04 15:24 17-ChaucersTaleOfSirThopas.txt",
                "   19   -rw-r--r--   1 jpace jpace   43249 2010-12-04 15:24 18-ChaucersTaleOfMeliboeus.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-TheMonksTale.txt",
                "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPriestsTale.txt",
                "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt",
                "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-TheCanonsYeomansTale.txt",
                "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-TheManciplesTale.txt",
                "   25   -rw-r--r--   1 jpace jpace   58300 2010-12-04 15:24 24-TheParsonsTale.txt",
                "   26   -rw-r--r--   1 jpace jpace    3650 2010-12-04 15:24 25-PrecesDeChauceres.txt",
               ]
    run_app_test expected, [ '--no-filter', 'TheS\w+Tale' ], fname
  end

  def test_one_file_no_matches
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "    1   -rw-r--r--   1 jpace jpace   52183 2010-12-04 15:24 00-ThePrologue.txt",
                "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-TheKnightsTale.txt",
                "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-TheMillersTale.txt",
                "    4   -rw-r--r--   1 jpace jpace   29296 2010-12-04 15:24 03-TheReevesTale.txt",
                "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-TheCooksTale.txt",
                "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-TheManOfLawsTale.txt",
                "    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-TheWifeOfBathsTale.txt",
                "    8   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-TheFriarsTale.txt",
                "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-TheSompnoursTale.txt",
                "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-TheClerksTale.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchantsTale.txt",
                "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                "   13   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-TheFranklinsTale.txt",
                "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-TheDoctorsTale.txt",
                "   15   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-ThePardonersTale.txt",
                "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-TheShipmansTale.txt",
                "   17   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-ThePrioresssTale.txt",
                "   18   -rw-r--r--   1 jpace jpace   14834 2010-12-04 15:24 17-ChaucersTaleOfSirThopas.txt",
                "   19   -rw-r--r--   1 jpace jpace   43249 2010-12-04 15:24 18-ChaucersTaleOfMeliboeus.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-TheMonksTale.txt",
                "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPriestsTale.txt",
                "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-TheSecondNunsTale.txt",
                "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-TheCanonsYeomansTale.txt",
                "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-TheManciplesTale.txt",
                "   25   -rw-r--r--   1 jpace jpace   58300 2010-12-04 15:24 24-TheParsonsTale.txt",
                "   26   -rw-r--r--   1 jpace jpace    3650 2010-12-04 15:24 25-PrecesDeChauceres.txt",
               ]
    run_app_test expected, [ '--no-filter', 'TheX\w+Tale' ], fname
  end

  def test_two_files
    fnames = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/04-TheCooksTale.txt' ]
    expected = [
                "[1m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    1   -rw-r--r--   1 jpace jpace   52183 2010-12-04 15:24 00-ThePrologue.txt",
                "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-TheKnightsTale.txt",
                "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-TheMillersTale.txt",
                "    4   -rw-r--r--   1 jpace jpace   29296 2010-12-04 15:24 03-TheReevesTale.txt",
                "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-TheCooksTale.txt",
                "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-TheManOfLawsTale.txt",
                "    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-TheWifeOfBathsTale.txt",
                "    8   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-TheFriarsTale.txt",
                "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-TheSompnoursTale.txt",
                "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-TheClerksTale.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchantsTale.txt",
                "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                "   13   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-TheFranklinsTale.txt",
                "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-TheDoct[30m[43mor[0msTale.txt",
                "   15   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-ThePardonersTale.txt",
                "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-TheShipmansTale.txt",
                "   17   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-ThePri[30m[43mor[0messsTale.txt",
                "   18   -rw-r--r--   1 jpace jpace   14834 2010-12-04 15:24 17-ChaucersTaleOfSirThopas.txt",
                "   19   -rw-r--r--   1 jpace jpace   43249 2010-12-04 15:24 18-ChaucersTaleOfMeliboeus.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-TheMonksTale.txt",
                "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPriestsTale.txt",
                "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-TheSecondNunsTale.txt",
                "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-TheCanonsYeomansTale.txt",
                "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-TheManciplesTale.txt",
                "   25   -rw-r--r--   1 jpace jpace   58300 2010-12-04 15:24 24-TheParsonsTale.txt",
                "   26   -rw-r--r--   1 jpace jpace    3650 2010-12-04 15:24 25-PrecesDeChauceres.txt",
                "[1m/proj/org/incava/glark/test/resources/04-TheCooksTale.txt[0m",
                "    1 Of many a pilgrim hast thou Christe's curse,",
                "    2 F[30m[43mor[0m of thy parsley yet fare they the w[30m[43mor[0mse.",
                "    3 ",
                "    4 That they have eaten in thy stubble goose:",
                "    5 F[30m[43mor[0m in thy shop doth many a fly go loose.",
                "    6 ",
                "    7 Now tell on, gentle Roger, by thy name,",
                "    8 But yet I pray thee be not wroth f[30m[43mor[0m game;",
                "    9 A man may say full sooth in game and play.",
               ]
    run_app_test expected, [ '--no-filter', 'or' ], *fnames
  end
end

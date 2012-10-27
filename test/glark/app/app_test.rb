#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pathname'
require 'tempfile'
require 'tc'
require 'glark/app/options'

class Glark::AppTestCase < Glark::TestCase
  def setup
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  def run_app_test expected, args, *files
    # files = [ file ]
    info "files: #{files}"
    gopt = Glark::Options.instance
    sio = StringIO.new
    gopt.run args
    gopt.out = sio

    glark = Glark::Runner.new gopt.expr, files
    files.each do |file|
      info "file: #{file}".red
      glark.search file
    end
    
    sio.close
    puts sio.string
    assert_equal expected.collect { |line| "#{line}\n" }.join(''), sio.string

    gopt.reset
  end

  def test_regexp_no_context
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-[30m[43mTheKnightsTale[0m.txt",
                "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[30m[43mTheMillersTale[0m.txt",
                "    4   -rw-r--r--   1 jpace jpace   29296 2010-12-04 15:24 03-[30m[43mTheReevesTale[0m.txt",
                "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-[30m[43mTheCooksTale[0m.txt",
                "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-[30m[43mTheManOfLawsTale[0m.txt",
                "    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-[30m[43mTheWifeOfBathsTale[0m.txt",
                "    8   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-[30m[43mTheFriarsTale[0m.txt",
                "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-[30m[43mTheClerksTale[0m.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "   13   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-[30m[43mTheFranklinsTale[0m.txt",
                "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoctorsTale[0m.txt",
                "   15   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-[30m[43mThePardonersTale[0m.txt",
                "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                "   17   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-[30m[43mThePrioresssTale[0m.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[43mTheMonksTale[0m.txt",
                "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-[30m[43mTheNunsPriestsTale[0m.txt",
                "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt",
                "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-[30m[43mTheCanonsYeomansTale[0m.txt",
                "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[30m[43mTheManciplesTale[0m.txt",
                "   25   -rw-r--r--   1 jpace jpace   58300 2010-12-04 15:24 24-[30m[43mTheParsonsTale[0m.txt",
               ]
    run_app_test expected, [ 'The\w+Tale' ], fname
  end

  def test_context
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "   11 -   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchantsTale.txt",
                "   12 -   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-TheSquiresTale.txt",
                "   13 -   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-TheFranklinsTale.txt",
                "   14 :   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoc[0mtorsTale.txt",
                "   15 +   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-ThePardonersTale.txt",
                "   16 +   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-TheShipmansTale.txt",
                "   17 +   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-ThePrioresssTale.txt",
               ]
    run_app_test expected, %w{ -3 TheDoc }, fname
  end

  def test_range_no_context
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "    8   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-[30m[43mTheFriarsTale[0m.txt",
                "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-[30m[43mTheClerksTale[0m.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "   13   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-[30m[43mTheFranklinsTale[0m.txt",
                "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoctorsTale[0m.txt",
                "   15   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-[30m[43mThePardonersTale[0m.txt",
                "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                "   17   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-[30m[43mThePrioresssTale[0m.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[43mTheMonksTale[0m.txt",
               ]
    run_app_test expected, [ '-R', '25%,20', 'The\w+Tale' ], fname
  end

  def test_range_with_context
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "    5 -   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-TheCooksTale.txt",
                "    6 -   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-TheManOfLawsTale.txt",
                "    7 -   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-TheWifeOfBathsTale.txt",
                "    8 :   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-[30m[43mTheFriarsTale[0m.txt",
                "    9 :   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "   10 :   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-[30m[43mTheClerksTale[0m.txt",
                "   11 :   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "   12 :   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "   13 :   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-[30m[43mTheFranklinsTale[0m.txt",
                "   14 :   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoctorsTale[0m.txt",
                "   15 :   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-[30m[43mThePardonersTale[0m.txt",
                "   16 :   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                "   17 :   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-[30m[43mThePrioresssTale[0m.txt",
                "   18 +   -rw-r--r--   1 jpace jpace   14834 2010-12-04 15:24 17-ChaucersTaleOfSirThopas.txt",
                "   19 +   -rw-r--r--   1 jpace jpace   43249 2010-12-04 15:24 18-ChaucersTaleOfMeliboeus.txt",
                "   20 :   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[43mTheMonksTale[0m.txt",
                "   21 +   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-TheNunsPriestsTale.txt",
                "   22 +   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-TheSecondNunsTale.txt",
                "   23 +   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-TheCanonsYeomansTale.txt",
               ]
    run_app_test expected, [ '-3', '-R', '25%,20', 'The\w+Tale' ], fname
  end

  def test_after_no_context
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "    8   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-[30m[43mTheFriarsTale[0m.txt",
                "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-[30m[43mTheClerksTale[0m.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "   13   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-[30m[43mTheFranklinsTale[0m.txt",
                "   14   -rw-r--r--   1 jpace jpace   15615 2010-12-04 15:24 13-[30m[43mTheDoctorsTale[0m.txt",
                "   15   -rw-r--r--   1 jpace jpace   39546 2010-12-04 15:24 14-[30m[43mThePardonersTale[0m.txt",
                "   16   -rw-r--r--   1 jpace jpace   25163 2010-12-04 15:24 15-[30m[43mTheShipmansTale[0m.txt",
                "   17   -rw-r--r--   1 jpace jpace   14979 2010-12-04 15:24 16-[30m[43mThePrioresssTale[0m.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[43mTheMonksTale[0m.txt",
                "   21   -rw-r--r--   1 jpace jpace   45326 2010-12-04 15:24 20-[30m[43mTheNunsPriestsTale[0m.txt",
                "   22   -rw-r--r--   1 jpace jpace   30734 2010-12-04 15:24 21-[30m[43mTheSecondNunsTale[0m.txt",
                "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-[30m[43mTheCanonsYeomansTale[0m.txt",
                "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[30m[43mTheManciplesTale[0m.txt",
                "   25   -rw-r--r--   1 jpace jpace   58300 2010-12-04 15:24 24-[30m[43mTheParsonsTale[0m.txt",
               ]
    run_app_test expected, [ '--after', '25%', 'The\w+Tale' ], fname
  end

  def test_before_no_context
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "    2   -rw-r--r--   1 jpace jpace  126084 2010-12-04 15:24 01-[30m[43mTheKnightsTale[0m.txt",
                "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[30m[43mTheMillersTale[0m.txt",
                "    4   -rw-r--r--   1 jpace jpace   29296 2010-12-04 15:24 03-[30m[43mTheReevesTale[0m.txt",
                "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-[30m[43mTheCooksTale[0m.txt",
                "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-[30m[43mTheManOfLawsTale[0m.txt",
                "    7   -rw-r--r--   1 jpace jpace   71054 2010-12-04 15:24 06-[30m[43mTheWifeOfBathsTale[0m.txt",
                "    8   -rw-r--r--   1 jpace jpace   22754 2010-12-04 15:24 07-[30m[43mTheFriarsTale[0m.txt",
                "    9   -rw-r--r--   1 jpace jpace   35994 2010-12-04 15:24 08-[30m[43mTheSompnoursTale[0m.txt",
                "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-[30m[43mTheClerksTale[0m.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "   12   -rw-r--r--   1 jpace jpace   42282 2010-12-04 15:24 11-[30m[43mTheSquiresTale[0m.txt",
                "   13   -rw-r--r--   1 jpace jpace   51996 2010-12-04 15:24 12-[30m[43mTheFranklinsTale[0m.txt",
               ]
    run_app_test expected, [ '--before', '50%', 'The\w+Tale' ], fname
  end

  def test_line_number_highlight
    fname = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [
                "     [36m3[0m   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[30m[43mTheMillersTale[0m.txt",
                "     [36m6[0m   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-[30m[43mTheManOfLawsTale[0m.txt",
                "    [36m11[0m   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "    [36m20[0m   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[43mTheMonksTale[0m.txt",
                "    [36m24[0m   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[30m[43mTheManciplesTale[0m.txt",
               ]
    run_app_test expected, [ '--line-number-color', 'cyan', 'TheM\w+Tale' ], fname
  end

  def test_file_names_no_highlight
    files = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [
                "[1m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[30m[43mTheMillersTale[0m.txt",
                "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-[30m[43mTheManOfLawsTale[0m.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[43mTheMonksTale[0m.txt",
                "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[30m[43mTheManciplesTale[0m.txt",
                "[1m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                "    3 02-[30m[43mThe_Millers_Tale[0m.txt",
                "    6 05-[30m[43mThe_Man_Of_Laws_Tale[0m.txt",
                "   11 10-[30m[43mThe_Merchants_Tale[0m.txt",
                "   20 19-[30m[43mThe_Monks_Tale[0m.txt",
                "   24 23-[30m[43mThe_Manciples_Tale[0m.txt",
               ]
    run_app_test expected, [ 'The.?M.*Tale' ], *files
  end

  def test_file_names_highlight
    files = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [
                "[33m/proj/org/incava/glark/test/resources/textfile.txt[0m",
                "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-[30m[43mTheMillersTale[0m.txt",
                "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-[30m[43mTheManOfLawsTale[0m.txt",
                "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-[30m[43mTheMerchantsTale[0m.txt",
                "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-[30m[43mTheMonksTale[0m.txt",
                "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-[30m[43mTheManciplesTale[0m.txt",
                "[33m/proj/org/incava/glark/test/resources/filelist.txt[0m",
                "    3 02-[30m[43mThe_Millers_Tale[0m.txt",
                "    6 05-[30m[43mThe_Man_Of_Laws_Tale[0m.txt",
                "   11 10-[30m[43mThe_Merchants_Tale[0m.txt",
                "   20 19-[30m[43mThe_Monks_Tale[0m.txt",
                "   24 23-[30m[43mThe_Manciples_Tale[0m.txt",
               ]
    run_app_test expected, [ '--file-color', 'yellow', 'The.?M.*Tale' ], *files  end
end

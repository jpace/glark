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

  def run_app_test expected, args, file
    gopt = Glark::Options.instance
    sio = StringIO.new
    gopt.run args
    gopt.out = sio

    glark = Glark::Runner.new gopt.expr, [ file ]    
    glark.search file
    
    sio.close
    puts sio.string
    assert_equal expected.collect { |line| "#{line}\n" }.join(''), sio.string

    gopt.reset
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
end

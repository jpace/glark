#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class StdInTestCase < AppTestCase
    def run_stdin_test expected, args
      file = '/proj/org/incava/glark/test/resources/textfile.txt'

      origstdin = $stdin

      inio = StringIO.new(::IO.readlines(file).join(''))
      
      gopt = AppOptions.new
      $stdin = inio

      outio = StringIO.new
      gopt.run(args)
      gopt.output_options.out = outio

      Log.verbose = true

      Runner.new gopt, gopt.fileset
      
      # inio.close
      outio.close

      $stdin = origstdin

      if false
        puts ",,,,,"
        puts outio.string
        puts ",,,,,"
      end
      
      result = outio.string

      actual = result.split "\n"
      ( 0 ... [ expected.length, actual.length ].max ).each do |idx|
        assert_equal expected[idx], actual[idx], "idx: #{idx}"
      end
    end

    def test_like_grep
      expected = [
                  "  -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-TheMillersTale.txt",
                  "  -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-TheManOfLawsTale.txt",
                  "  -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-TheMerchantsTale.txt",
                  "  -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-TheMonksTale.txt",
                  "  -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-TheManciplesTale.txt",
                 ]
      run_stdin_test expected, [ '-g', 'M.*Tale' ]
    end

    def test_like_glark
      expected = [
                  "    3   -rw-r--r--   1 jpace jpace   45450 2010-12-04 15:24 02-The[30m[43mMillersTale[0m.txt",
                  "    6   -rw-r--r--   1 jpace jpace   63290 2010-12-04 15:24 05-The[30m[43mManOfLawsTale[0m.txt",
                  "   11   -rw-r--r--   1 jpace jpace   65852 2010-12-04 15:24 10-The[30m[43mMerchantsTale[0m.txt",
                  "   20   -rw-r--r--   1 jpace jpace   49747 2010-12-04 15:24 19-The[30m[43mMonksTale[0m.txt",
                  "   24   -rw-r--r--   1 jpace jpace   21141 2010-12-04 15:24 23-The[30m[43mManciplesTale[0m.txt",
                 ]
      run_stdin_test expected, [ 'M.*Tale' ]
    end
  end
end

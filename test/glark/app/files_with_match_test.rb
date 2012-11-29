#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

module Glark
  class FilesWithMatchTestCase < AppTestCase
    def test_one_of_one
      file = '/proj/org/incava/glark/test/resources/textfile.txt'
      expected = [ file ]
      run_app_test expected, [ '-l', 'TheM\w+Tale' ], file
    end

    def test_one_of_two
      files = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
      expected = [ files[0] ]
      run_app_test expected, [ '-l', 'TheM\w+Tale' ], *files
    end

    def test_two_of_two
      files = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
      expected = files
      run_app_test expected, [ '-l', 'The.*M\w+Tale' ], *files
    end

    def test_null_two
      files = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
      expected = files.collect { |x| "#{x}\000" }.join('')
      run_app_test_exact_output expected, [ '-l', '-Z', 'The.*M\w+Tale' ], *files
    end
  end
end

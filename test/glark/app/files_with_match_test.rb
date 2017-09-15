#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class FilesWithMatchTestCase < AppTestCase
    include Glark::Resources
    
    def test_one_of_one
      file = to_path "textfile.txt"
      expected = [ file ]
      run_app_test expected, [ '-l', 'TheM\w+Tale' ], file
    end

    def test_one_of_two
      files = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = [ files[0] ]
      run_app_test expected, [ '-l', 'TheM\w+Tale' ], *files
    end

    def test_two_of_two
      files = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = files
      run_app_test expected, [ '-l', 'The.*M\w+Tale' ], *files
    end

    def test_null_two
      files = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = files.collect { |x| "#{x}\000" }.join('')
      run_app_test_exact_output expected, [ '-l', '-Z', 'The.*M\w+Tale' ], *files
    end
  end
end

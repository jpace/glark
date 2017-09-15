#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class FilesWithoutMatchTestCase < AppTestCase
    include Glark::Resources
    
    def test_one_of_one
      file = to_path "textfile.txt"
      expected = [ file ]
      run_app_test expected, [ '-L', 'TheX\w+Tale' ], file
    end

    def test_one_of_two
      files = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = [ files[1] ]
      run_app_test expected, [ '-L', 'TheM\w+Tale' ], *files
    end

    def test_none_of_two
      files = [ to_path("textfile.txt"), to_path("filelist.txt") ]
      expected = [ ]
      run_app_test expected, [ '-L', 'The.*P\w+Tale' ], *files
    end
  end
end

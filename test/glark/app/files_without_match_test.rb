#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::FilesWithoutMatchTestCase < Glark::AppTestCase
  def test_one_of_one
    file = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [ file ]
    run_app_test expected, [ '-L', 'TheX\w+Tale' ], file
  end

  def test_one_of_two
    files = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [ files[1] ]
    run_app_test expected, [ '-L', 'TheM\w+Tale' ], *files
  end

  def test_none_of_two
    files = [ '/proj/org/incava/glark/test/resources/textfile.txt', '/proj/org/incava/glark/test/resources/filelist.txt' ]
    expected = [ ]
    run_app_test expected, [ '-L', 'The.*P\w+Tale' ], *files
  end
end

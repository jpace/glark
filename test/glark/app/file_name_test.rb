#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::FileNameTestCase < Glark::AppTestCase
  def test_glark_one
    file = '/proj/org/incava/glark/test/resources/textfile.txt'
    expected = [ file ]
    run_app_test expected, [ '-l', 'TheM\w+Tale' ], file
  end

  def test_glark_two
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

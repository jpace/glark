#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::ArgTestCase < Glark::AppTestCase
  def test_binaries_included_as_specified
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [
                'Binary file /proj/org/incava/glark/test/resources/textfile.txt.gz matches',
               ]
    run_app_test expected, [ 'g.*t.*e\b' ], fname
  end
end

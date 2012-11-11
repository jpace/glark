#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::DirNameTestCase < Glark::AppTestCase
  def test_skip_svn
    dirname = '/proj/org/incava/glark/test/resources'
    expected = [
                "[1m/proj/org/incava/glark/test/resources/canterbury/franklin/tale.txt[0m",
                "   10 That well unnethes durst [30m[43mthis knight for drea[0md,",
                "  149 Why have ye wrought [30m[43mthis work unrea[0msonable?",
                "  366 Let I [30m[43mthis woeful crea[0mture lie;",
               ]
    run_app_test expected, [ '--directories=recurse', 'this.*rea' ], dirname
  end
end

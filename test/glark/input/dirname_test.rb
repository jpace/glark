#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class DirNameTestCase < AppTestCase
    include Glark::Resources
    
    def test_skip_svn
      expected = [
                  "[1m" + RES_DIR + "/canterbury/franklin/tale.txt[0m",
                  "   10 That well unnethes durst [30m[43mthis knight for drea[0md,",
                  "  149 Why have ye wrought [30m[43mthis work unrea[0msonable?",
                  "  366 Let I [30m[43mthis woeful crea[0mture lie;",
                 ]
      run_app_test expected, [ '--directories=recurse', 'this.*rea' ], RES_DIR
    end

    def test_match_basename
      dirnames = [ RES_DIR + "/canterbury", TEST_DIR + "/glark" ]
      expected = [
                  "[1m" + RES_DIR + "/canterbury/prologue.txt[0m",
                  "  187 He gave not of the te[30m[43mxt a pulled he[0mn,",
                  "  192 This ilke te[30m[43mxt held he not worth an oyste[0mr;",
                  "  291 Betwi[30m[43mxte Middleburg and Orewe[0mll",
                 ]
      run_app_test expected, [ '-r', '--match-dirname=canterbury', 'xt.*e' ], *dirnames
    end

    def test_not_basename
      dirnames = [ TEST_DIR ]
      expected = [
                  "[1m" + RES_DIR + "/canterbury/franklin/tale.txt[0m",
                  "   80 That is betwi[30m[43mxt a husband and his wife[0m?",
                  "[1m" + RES_DIR + "/canterbury/prologue.txt[0m",
                  "  187 He gave not of the te[30m[43mxt a pulled he[0mn,",
                  "  192 This ilke te[30m[43mxt held he not worth an oyste[0mr;",
                  "  291 Betwi[30m[43mxte Middleburg and Orewe[0mll",
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "   10 te[30m[43mxt-color-3: underline mage[0mnta",
                 ]
      run_app_test expected, [ '-r', '--skip-dirname=glark', 'xt.*e' ], *dirnames
    end

    def test_match_pathname
      dirnames = [ TEST_DIR + "/glark", RES_DIR ]
      puts "dirnames: #{dirnames}"
      expected = [
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "   10 te[30m[43mxt-color-3: underline mage[0mnta",
                 ]
      run_app_test expected, [ '-r', '--match-dirpath', '^.*es$', 'xt.*e' ], *dirnames
    end

    def test_not_pathname
      dirnames = [ TEST_DIR + 'glark', RES_DIR ]
      expected = [
                  "[1m" + RES_DIR + "/canterbury/franklin/tale.txt[0m",
                  "   80 That is betwi[30m[43mxt a husband and his wife[0m?",
                  "[1m" + RES_DIR + "/canterbury/prologue.txt[0m",
                  "  187 He gave not of the te[30m[43mxt a pulled he[0mn,",
                  "  192 This ilke te[30m[43mxt held he not worth an oyste[0mr;",
                  "  291 Betwi[30m[43mxte Middleburg and Orewe[0mll",
                  "[1m" + RES_DIR + "/rcfile.txt[0m",
                  "   10 te[30m[43mxt-color-3: underline mage[0mnta",
                 ]
      run_app_test expected, [ '-r', '--skip-dirpath', 'test/glark', 'xt.*e' ], *dirnames
    end
  end
end

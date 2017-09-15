#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/resources'

module Glark
  class ExtTestCase < AppTestCase
    include Glark::Resources
    
    def test_match_single
      expected = [
                  "[1m" + RES_DIR + "/add.rb[0m",
                  "    5   def ini[30m[43mtialize[0m x, y",
                  "[1m" + RES_DIR + "/greet.rb[0m",
                  "    5   def ini[30m[43mtialize name[0m",
                  "    6     pu[30m[43mts \"hello, \" + name[0m",
                  "   10 Gree[30m[43mt.ne[0mw ARGV.shift || \"world\"",
                 ]
      run_app_test expected, [ '-r', '--match-ext', 'rb', 't.*e' ], RES_DIR
    end

    def test_not_single
      expected = [
                  "[1m" + RES_DIR + "/canterbury/franklin/prologue.txt[0m",
                  "   60 Have me e[30m[43mxcused of my[0m rude speech.",
                  "[1m" + RES_DIR + "/canterbury/franklin/tale.txt[0m",
                  "  184 And this was on the si[30m[43mxth morrow of May[0m,",
                  "  560 Neither his collect, nor his e[30m[43mxpanse y[0mears,",
                  "  706 Why should I more e[30m[43mxamples hereof say[0mn?",
                  "  813 Than to depart the love betwi[30m[43mxt y[0mou two.",
                  "[1m" + RES_DIR + "/canterbury/prologue.txt[0m",
                  "  192 This ilke te[30m[43mxt held he not worth an oy[0mster;",
                 ]
      run_app_test expected, [ '-r', '--skip-ext', 'rb', 'x.*y' ], RES_DIR
    end

    def test_match_multiple
      expected = [
                  "[1m" + RES_DIR + "/add.rb[0m",
                  "    5   def initialize [30m[43mx, y[0m",
                  "    6     puts [30m[43mx.to_s + \" + \" + y.to_s + \" = \" + (x.to_i + y[0m.to_i).to_s",
                  "[1m" + RES_DIR + "/canterbury/franklin/prologue.txt[0m",
                  "   60 Have me e[30m[43mxcused of my[0m rude speech.",
                  "[1m" + RES_DIR + "/canterbury/franklin/tale.txt[0m",
                  "  184 And this was on the si[30m[43mxth morrow of May[0m,",
                  "  560 Neither his collect, nor his e[30m[43mxpanse y[0mears,",
                  "  706 Why should I more e[30m[43mxamples hereof say[0mn?",
                  "  813 Than to depart the love betwi[30m[43mxt y[0mou two.",
                  "[1m" + RES_DIR + "/canterbury/prologue.txt[0m",
                  "  192 This ilke te[30m[43mxt held he not worth an oy[0mster;",
                 ]
      run_app_test expected, [ '-r', '--match-ext', 'rb', '--match-ext', 'txt', 'x.*y' ], RES_DIR
    end

    def test_not_multiple
      expected = [
                  "[1m" + RES_DIR + "/cat.pl[0m",
                  "    6 [30m[43mprint[0m <>;",
                 ]
      run_app_test expected, [ '-r', '--skip-ext', 'rb', '--not-ext', 'txt', 'p.*t' ], RES_DIR
    end
  end
end

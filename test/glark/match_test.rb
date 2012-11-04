#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/match/factory'
require 'tc'
require 'stringio'

class Glark::MatchTestCase < Glark::TestCase
  def run_test expected, fname, exprargs
    info "exprargs: #{exprargs}".yellow
    opts = Glark::Options.new
    
    # Egads, Ruby is fun. Converting a maybe-array into a definite one:
    args = [ exprargs ].flatten

    expr = opts.match_options.read_expression args
    
    sio = StringIO.new
    opts.out = sio

    files = [ fname ]
    glark = Glark::Runner.new opts, expr, files
    glark.search fname
    
    result = sio.string
    assert_equal expected.collect { |line| "#{line}\n" }.join(''), result
  end

  def get_colors patterns
    defcolors = Text::ANSIHighlighter::DEFAULT_COLORS

    patterns.collect_with_index do |pat, pidx|
      color = Text::ANSIHighlighter.make defcolors[pidx % defcolors.length]
      [ pat, color ]
    end
  end

  def run_abc_test expected, exprargs
    fname = '/proj/org/incava/glark/test/resources/abcfile.txt'
    run_test expected, fname, exprargs
  end

  def test_plain_old_match_first_line
    expected = [
                "    1 [30m[43mA[0mBC"
               ]
    
    run_abc_test expected, 'A'
  end

  def test_plain_old_match_middle_line
    expected = [
                "    4 J[30m[43mK[0mL"
               ]

    run_abc_test expected, 'K'
  end

  def test_regexp_or
    expected = [
                "    4 J[30m[43mK[0mL",
                "    5 M[30m[42mN[0mO"
               ]    

    run_abc_test expected, '(K)|(N)'
  end

  def run_z_test expected, exprargs
    fname = '/proj/org/incava/glark/test/resources/zfile.txt'
    run_test expected, fname, exprargs
  end

  def test_multicolor_alt_regexp_one_match
    patterns = %w{ nul }

    expected = [
                "    6 zo[30m[43mnul[0mae"
               ]

    exprargs = patterns.collect { |x| "(#{x})" }.join('|')
    
    run_z_test expected, exprargs
  end

  def test_multicolor_alt_regexp_3_patterns
    patterns = %w{ oo ae z }

    expected = [
                "    1 [30m[45mz[0maffres",
                "    2 [30m[45mz[0mo[30m[42mae[0ma",
                "    3 [30m[45mz[0mo[30m[42mae[0ma's",
                "    4 [30m[45mz[0moea",
                "    5 [30m[45mz[0moeas",
                "    6 [30m[45mz[0monul[30m[42mae[0m",
                "    7 [30m[45mz[0m[30m[43moo[0mea",
                "    8 [30m[45mz[0m[30m[43moo[0me[30m[42mae[0m",
                "    9 [30m[45mz[0m[30m[43moo[0meal",
                "   10 [30m[45mz[0m[30m[43moo[0meas",
                "   11 [30m[45mz[0m[30m[43moo[0mecia",
                "   12 [30m[45mz[0m[30m[43moo[0mecium",
                "   13 [30m[45mz[0m[30m[43moo[0mgloe[30m[42mae[0m",
                "   14 [30m[45mz[0m[30m[43moo[0mgloeal",
                "   15 [30m[45mz[0m[30m[43moo[0mgloeas",
                "   16 [30m[45mz[0myg[30m[42mae[0mnid",
               ]

    exprargs = patterns.collect { |x| "(#{x})" }.join('|')
    
    run_z_test expected, exprargs
  end

  def test_multicolor_or_expression_3_patterns
    patterns = %w{ oo ae z }

    expected = [
                "    1 [30m[45mz[0maffres",
                "    2 [30m[45mz[0mo[30m[42mae[0ma",
                "    3 [30m[45mz[0mo[30m[42mae[0ma's",
                "    4 [30m[45mz[0moea",
                "    5 [30m[45mz[0moeas",
                "    6 [30m[45mz[0monul[30m[42mae[0m",
                "    7 [30m[45mz[0m[30m[43moo[0mea",
                "    8 [30m[45mz[0m[30m[43moo[0me[30m[42mae[0m",
                "    9 [30m[45mz[0m[30m[43moo[0meal",
                "   10 [30m[45mz[0m[30m[43moo[0meas",
                "   11 [30m[45mz[0m[30m[43moo[0mecia",
                "   12 [30m[45mz[0m[30m[43moo[0mecium",
                "   13 [30m[45mz[0m[30m[43moo[0mgloe[30m[42mae[0m",
                "   14 [30m[45mz[0m[30m[43moo[0mgloeal",
                "   15 [30m[45mz[0m[30m[43moo[0mgloeas",
                "   16 [30m[45mz[0myg[30m[42mae[0mnid",
               ]

    exprargs = patterns[0 ... -1].collect { '--or' } + patterns
    info "exprargs: #{exprargs}".on_blue
    
    run_z_test expected, exprargs
  end

  def test_and_expression_2_lines_apart
    Log.level = Log::DEBUG
    info "self: #{self}"
    
    # 'ea', 'ec' within 2 lines of each other:
    expected = [
                "    9 zoo[30m[43mea[0ml",
                "   10 zoo[30m[43mea[0ms",
                "   11 zoo[30m[42mec[0mia",
                "   12 zoo[30m[42mec[0mium",
                "   13 zooglo[30m[43mea[0me",
                "   14 zooglo[30m[43mea[0ml"
               ]
    
    patterns = %w{ ea ec }
    
    exprargs = [ "--and", "2" ] + patterns

    run_z_test expected, exprargs
  end

  def test_and_expression_3_lines_apart
    expected = [
                "    3 zo[30m[43maea[0m's",
                "    4 zoea",
                "    5 zoeas",
                "    6 zon[30m[42mula[0me"
               ]

    patterns = %w{ aea ula }
    
    exprargs = [ "--and", "3" ] + patterns

    run_z_test expected, exprargs
  end

  def test_and_expression_entire_file
    expected = [
                "    1 z[30m[43maff[0mres",
                "    2 zoaea",
                "    3 zoaea's",
                "    4 zoea",
                "    5 zoeas",
                "    6 zonulae",
                "    7 zooea",
                "    8 zooeae",
                "    9 zooeal",
                "   10 zooeas",
                "   11 zooecia",
                "   12 zooecium",
                "   13 zoogloeae",
                "   14 zoogloeal",
                "   15 zoogloeas",
                "   16 z[30m[42myga[0menid",
               ]

    patterns = %w{ aff yga }    
    exprargs = [ "--and", "-1" ] + patterns

    run_z_test expected, exprargs
  end
end

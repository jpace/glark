#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/format'
require 'glark/output/file_header'
require 'glark/output/matching_format'

# -------------------------------------------------------
# Glark output format
# -------------------------------------------------------

class GlarkOutputFormat < MatchingOutputFormat
  def initialize file, options
    super

    @file_header = nil          # not nil after file header written
    
    @has_context = options.after != 0 || options.before != 0    
    @fname_highlighter = options.highlight && options.file_highlight
    @lnum_highlighter = options.line_number_highlight
  end

  # prints the line, and adjusts for the fact that in our world, lines are
  # 0-indexed, whereas they are displayed as if 1-indexed.
  def print_line lnum, ch = nil 
    log { "lnum #{lnum}, ch: '#{ch}'" }
    lnums = @file.get_region lnum 
    log { "lnums(#{lnum}): #{lnums}".on_blue }
    return unless lnums
    log { "printing" }
    lnums.each do |ln|
      println ln, ch 
    end
  end

  def show_file_header
    if @show_file_name && @file_header.nil?
      @file_header = FileHeader.new displayed_name, @fname_highlighter
      @file_header.print @out
    end
  end

  def print_line_number lnum 
    if @lnum_highlighter
      lnumstr = (lnum + 1).to_s
      pad = " " * ([5 - lnumstr.length, 0].max)
      @out.print pad + " " + @lnum_highlighter.highlight(lnumstr) + " "
    else
      super
    end
  end

  def write_matching from, to
    show_file_header
    super
  end

  def write_nonmatching from, to
    show_file_header
    super
  end

  def println ln, ch 
    info "@show_line_numbers: #{@show_line_numbers}".on_yellow
    if @show_line_numbers
      print_line_number ln 
    end
    
    if ch && @has_context
      @out.printf "%s ", ch
    end

    line = get_line_to_print ln 
    log { "line: #{line}" }
    
    @out.puts line
  end

  def add_match startline, endline
    super
    
    st = [0, startline - @before].max
    @stati.set_match startline - @before, startline, endline, endline + @after
  end
end

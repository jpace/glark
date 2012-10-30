#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/format'
require 'glark/output/matching_format'
require 'glark/output/file_header'

class NonFilterFormat < MatchingOutputFormat
  def initialize fname, fmtopts
    super
    @file_header = nil          # not nil after file header written    
    @fname_highlighter = fmtopts.highlight && fmtopts.file_highlight
    @lnum_highlighter = fmtopts.line_number_highlight
  end

  def display_matches?
    false
  end

  def process_end lnum
    show_file_header
    write_all
  end

  def write_all
    show_file_header
    (0 ... @file.get_lines.length).each do |ln|
      print_line ln  
    end
  end

  # -------------------------------------------------------
  # these could be mixed in from GlarkFormat:
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

  def println ln, ch 
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
end

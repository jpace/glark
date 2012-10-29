#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/results/format'
require 'glark/results/file_header'

# -------------------------------------------------------
# Glark output format
# -------------------------------------------------------

class GlarkOutputFormat < OutputFormat
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
    lnums = @file.get_range lnum 
    log { "lnums(#{lnum}): #{lnums}".on_blue }
    return unless lnums
    log { "printing" }
    lnums.each do |ln|
      println ln, ch 
    end
  end

  def show_file_header
    if @show_file_name && @file_header.nil?
      @file_header = FileHeader.new @label || @file.fname, @fname_highlighter
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
 
  def write_count matching = true 
    ct = matching ? @file.count : @file.get_lines.size - @file.count
    @out.puts "    " + ct.to_s
  end

  def write_matches matching, from, to 
    show_file_header
    super matching, from, to 
  end

  def write_all
    show_file_header
    super
  end

  def println ln, ch 
    if show_line_numbers
      print_line_number ln 
    end
    
    if ch && @has_context
      @out.printf "%s ", ch
    end

    line = get_line_to_print ln 
    log { "line: #{line}" }
    
    @out.puts line
  end
end

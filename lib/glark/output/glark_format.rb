#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/format'

# -------------------------------------------------------
# Glark output format
# -------------------------------------------------------

class GlarkOutputFormat < OutputFormat
  def initialize infile, options
    super

    @file_header_shown = false
    
    @has_context = options.after != 0 || options.before != 0    
    @fname_highlighter = options.highlight && options.file_highlight
    @lnum_highlighter = options.line_number_highlight
  end

  # prints the line, and adjusts for the fact that in our world, lines are
  # 0-indexed, whereas they are displayed as if 1-indexed.
  def print_line lnum, ch = nil 
    log { "lnum #{lnum}, ch: '#{ch}'" }
    begin
      lnums = @infile.get_range lnum 
      log { "lnums(#{lnum}): #{lnums}" }
      if lnums
        log { "printing" }
        lnums.each do |ln|
          println ln, ch 
        end
      end
    rescue => e
      # puts e
      # puts e.backtrace
    end
  end

  def show_file_header
    if @show_file_name && !@file_header_shown
      fname = @label || @infile.fname
      fname = @fname_highlighter.highlight(fname) if @fname_highlighter
      
      @out.puts fname
    end
    @file_header_shown = true
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
    ct = matching ? @infile.count : @infile.get_lines.size - @infile.count
    @out.puts "    " + ct.to_s
  end

  def write_matches matching, from = nil, to = nil 
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
    
    if ch && has_context
      @out.printf "%s ", ch
    end

    line = get_line_to_print ln 
    log { "line: #{line}" }
    
    @out.puts line
  end
end

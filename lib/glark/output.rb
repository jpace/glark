#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Glark output.

require 'English'

require 'rubygems'
require 'riel'

require 'glark/options'
require 'glark/input'

class Results
  include Loggable
  
end

class OutputFormat < Results

  attr_reader :formatted, :infile, :show_file_name, :has_context

  def initialize infile, show_file_names 
    @infile            = infile
    @show_file_name    = show_file_names
    @formatted         = []
    @has_context       = false

    opts               = GlarkOptions.instance

    @label             = opts.label
    @out               = opts.out
    @show_break        = opts.show_break
    @show_line_numbers = opts.show_line_numbers
  end

  # Prints the line, which is assumed to be 0-indexed, and is thus adjusted by
  # one.
  def print_line_number lnum 
    @out.printf "%5d ", lnum + 1
  end

  # prints the line, and adjusts for the fact that in our world, lines are
  # 0-indexed, whereas they are displayed as if 1-indexed.
  def print_line lnum, ch = nil 
    log { "lnum #{lnum}, ch: '#{ch}'" }
    begin
      lnums = @infile.get_range lnum 
      log { "lnums(#{lnum}): #{lnums}" }
      if lnums
        lnums.each do |ln|
          if show_line_numbers
            print_line_number ln 
            if ch && has_context
              @out.printf "%s ", ch
            end
          end
          line = @formatted[ln] || @infile.get_line(ln)
          @out.puts line
        end
      end
    rescue => e
      # puts e
      # puts e.backtrace
    end
  end

  def write_matches matching, from, to 
    if @infile.count
      write_count matching 
    elsif matching
      firstline = from ? from : 0
      lastline  = to   ? to   : @infile.get_lines.length - 1

      (firstline .. lastline).each do |ln|
        if @infile.stati[ln]
          unless @infile.stati[ln] == InputFile::WRITTEN
            if firstline > 0 && !@infile.stati[ln - 1] && has_context && @show_break
              @out.puts "  ---"
            end
            
            print_line ln, @infile.stati[ln]  

            @infile.stati[ln] = InputFile::WRITTEN
          end
        end

      end
    else
      firstline = from ? from : 0
      lastline  = to ? to : @infile.get_lines.length - 1
      (firstline .. lastline).each do |ln|
        if @infile.stati[ln] != InputFile::WRITTEN && @infile.stati[ln] != ":"
          log { "printing #{ln}" }
          print_line ln 
          @infile.stati[ln] = InputFile::WRITTEN
        end
      end
    end
  end

  def write_all
    (0 ... @infile.get_lines.length).each do |ln|
      print_line ln  
    end
  end

  def get_line_to_print lnum 
    formatted[lnum] || infile.get_line(lnum)
  end

  def show_line_numbers
    @show_line_numbers
  end

end


# -------------------------------------------------------
# Glark output format
# -------------------------------------------------------

class GlarkOutputFormat < OutputFormat

  def initialize infile, show_file_names 
    super

    opts = GlarkOptions.instance

    @has_context = opts.after != 0 || opts.before != 0
    @file_header_shown = false
    if @highlight = opts.highlight
      @fname_highlighter = opts.file_highlight
    end
    @lnum_highlighter = opts.line_number_highlight
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
    if show_file_name && !@file_header_shown
      fname = @label || @infile.fname
      fname = @fname_highlighter.highlight(fname) if @highlight
      
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


class GlarkMatchList < GlarkOutputFormat
  attr_reader :matches

  def initialize infile, show_file_names 
    super
    @matches = Array.new
  end

  def write_matches matching, from, to 
    stack "matching: #{matching}"
    from.upto(to) do |line|
      @matches[line] = true
    end
    log { "matches: #{@matches}" }
  end

end


# -------------------------------------------------------
# Grep output format
# -------------------------------------------------------

# This matches grep, mostly. It is for running within emacs, thus,
# it does not support context or highlighting.
class GrepOutputFormat < OutputFormat

  def write_count matching = true 
    print_file_name
    ct = matching ? @infile.count : @infile.get_lines.length - @infile.count
    puts ct
  end

  # prints the line, and adjusts for the fact that in our world, lines are
  # 0-indexed, whereas they are displayed as if 1-indexed.
  def print_line lnum, ch = nil 
    ln = get_line_to_print lnum 

    if ln
      print_file_name
      if show_line_numbers
        printf "%d: ", lnum + 1
      end
      
      print ln
    end
  end

  def print_file_name
    if show_file_name
      fname = @label || @infile.fname
      print @infile.fname, ":"
    end
  end

end

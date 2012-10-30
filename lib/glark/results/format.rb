#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Glark output.

require 'rubygems'
require 'riel'
require 'glark/app/options'
require 'glark/io/file'
require 'glark/io/line_status'

class Results
  include Loggable

  attr_reader :count

  def initialize
    @count = 0
  end

  def matched?
    @count > 0
  end

  def add_match
    @count += 1
  end
end

class FormatOptions
  attr_accessor :after
  attr_accessor :before
  attr_accessor :file_highlight
  attr_accessor :file_names_only
  attr_accessor :filter
  attr_accessor :highlight
  attr_accessor :invert_match
  attr_accessor :label
  attr_accessor :line_number_highlight
  attr_accessor :out
  attr_accessor :show_file_names
  attr_accessor :show_line_numbers
  attr_accessor :write_null

  def initialize 
    @after = nil
    @before = nil
    @file_highlight = nil
    @file_names_only = nil
    @filter = filter
    @highlight = nil
    @invert_match = nil
    @label = nil
    @line_number_highlight = nil
    @out = nil
    @show_file_names = nil
    @show_line_numbers = nil
    @write_null = nil
  end
end

class OutputFormat < Results
  attr_reader :formatted

  def initialize file, fmtopts
    super()

    @file = file
    @formatted = []
    @has_context = false

    @after = fmtopts.after
    @before = fmtopts.before
    @filter = fmtopts.filter
    @file_names_only = fmtopts.file_names_only
    @invert_match = fmtopts.invert_match
    @label = fmtopts.label
    @out = fmtopts.out
    @show_file_name = fmtopts.show_file_names
    @show_line_numbers = fmtopts.show_line_numbers
    @stati = Glark::LineStatus.new
    @write_null = fmtopts.write_null
  end

  def displayed_name
    @label || @file.fname
  end

  # Prints the line, which is assumed to be 0-indexed, and is thus adjusted by
  # one.
  def print_line_number lnum 
    @out.printf "%5d ", lnum + 1
  end

  # prints the line, and adjusts for the fact that in our world, lines are
  # 0-indexed, whereas they are displayed as if 1-indexed.
  def print_line lnum, ch = nil 
    raise "error: print_line must be implemented by a formatter subclass"
  end

  def write_matching from, to
    (from .. to).each do |ln|
      next unless @stati.char(ln) && !@stati.is_written?(ln)

      # this used to be conditional on show_break, but no more
      if from > 0 && !@stati.char(ln - 1) && @has_context
        @out.puts "  ---"
      end
      
      print_line ln, @stati.char(ln)
      @stati.set_as_written ln
    end
  end

  def write_nonmatching from, to
    (from .. to).each do |ln|
      next if @stati.is_written?(ln) || @stati.char(ln) == ":"
      log { "printing #{ln}" }
      print_line ln 
      @stati.set_as_written ln
    end
  end

  def write_matches matching, from, to 
    if matching
      write_matching from, to
    else
      write_nonmatching from, to
    end
  end

  def write_all
    (0 ... @file.get_lines.length).each do |ln|
      print_line ln  
    end
  end

  def get_line_to_print lnum 
    @formatted[lnum] || @file.get_line(lnum)
  end

  def show_line_numbers
    @show_line_numbers
  end

  def print_only_file_name write_null
    if write_null
      @out.print @file.fname + "\0"
    else
      @out.puts @file.fname
    end
  end

  def process_end matched, lnum
    info "matched: #{matched}".on_blue
    if @file_names_only
      if matched != @invert_match
        print_only_file_name @write_null
      end
    elsif @filter
      if @invert_match
        write_matches false, 0, lnum
      elsif matched
        write_matches true, 0, lnum
      end
    else
      write_all
    end
  end

  def mark_as_match startline, endline
    add_match

    # even with multi-line matches (--and expressions), we'll display
    # only the first matching line, not the range between the matches.

    if kind_of? GrepOutputFormat
      endline = startline
    end

    st = [0, startline - @before].max
    @stati.set_match startline - @before, startline, endline, endline + @after
  end
end

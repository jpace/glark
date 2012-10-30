#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Output for displayed lines.

require 'glark/io/file'
require 'glark/io/line_status'
require 'glark/results/format'

class MatchingOutputFormat < OutputFormat
  def initialize file, fmtopts
    super

    @file = file
    @has_context = false

    @after = fmtopts.after
    @before = fmtopts.before
    @invert_match = fmtopts.invert_match
    @label = fmtopts.label
    @match_limit = fmtopts.match_limit
    @out = fmtopts.out
    @show_file_name = fmtopts.show_file_names
    @show_line_numbers = fmtopts.show_line_numbers
    @stati = Glark::LineStatus.new
  end

  def display_matches?
    true
  end

  def at_match_limit?
    @match_limit && @count >= @match_limit
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

  def write_matches from, to 
    if @invert_match
      write_nonmatching from, to
    else
      write_matching from, to
    end
  end

  def process_end lnum
    if @invert_match
      write_nonmatching 0, lnum
    elsif matched?
      write_matching 0, lnum
    end
  end

  def add_match startline, endline
    super
  end

  def process_match startline, endline, fromline, toline
    add_match startline, endline
    
    if display_matches?
      write_matches fromline, toline
    end
    return at_match_limit?
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Output for displayed lines.

require 'glark/io/file/file'
require 'glark/output/line_status'
require 'glark/output/common'

class Lines < Common
  def initialize file, spec
    super

    @print_context = false
    
    context = spec.context
    @after = context && context.after
    @before = context && context.before

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
    raise "error: print_line must be implemented by an output subclass"
  end

  def write_matching from, to
    (from .. to).each do |ln|
      next unless @stati.char(ln) && !@stati.is_written?(ln)

      # this used to be conditional on show_break, but no more
      if from > 0 && !@stati.char(ln - 1) && @print_context
        @out.puts "  ---"
      end
      
      print_line ln, @stati.char(ln)
      @stati.set_as_written ln
    end
  end

  def write_nonmatching from, to
    (from .. to).each do |ln|
      next if @stati.is_written?(ln) || @stati.char(ln) == ':'
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

  def process_match startline, endline, fromline, toline
    add_match startline, endline
    
    if display_matches?
      write_matches fromline, toline
    end
    return at_match_limit?
  end

  def set_status startline, endline
    fromline = [0, startline - @before].max
    toline = endline + @after
    @stati.set_match fromline, startline, endline, toline
  end
end

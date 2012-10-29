#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Glark output.

require 'rubygems'
require 'riel'
require 'glark/app/options'
require 'glark/io/file'

class FormatOptions
  attr_accessor :after
  attr_accessor :before
  attr_accessor :file_highlight
  attr_accessor :highlight
  attr_accessor :label
  attr_accessor :line_number_highlight
  attr_accessor :out
  attr_accessor :show_file_names
  attr_accessor :show_line_numbers

  def initialize 
    @after = nil
    @before = nil
    @file_highlight = nil
    @highlight = nil
    @label = nil
    @line_number_highlight = nil
    @out = nil
    @show_file_names = nil
    @show_line_numbers = nil
  end
end

class OutputFormat
  include Loggable
  
  attr_reader :formatted

  def initialize file, fmtopts
    @file              = file
    @formatted         = []
    @has_context       = false
    @label             = fmtopts.label
    @out               = fmtopts.out
    @show_file_name    = fmtopts.show_file_names
    @show_line_numbers = fmtopts.show_line_numbers
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
    stati = @file.stati
    
    (from .. to).each do |ln|
      next unless stati[ln] && !stati.is_written?(ln)

      # this used to be conditional on show_break, but no more
      if from > 0 && !stati[ln - 1] && @has_context
        @out.puts "  ---"
      end
      
      print_line ln, stati[ln]  
      stati.set_as_written ln
    end
  end

  def write_nonmatching from, to
    stati = @file.stati

    (from .. to).each do |ln|
      next if stati.is_written?(ln) || stati[ln] == ":"
      log { "printing #{ln}" }
      print_line ln 
      stati.set_as_written ln
    end
  end

  def write_matches matching, from, to 
    if @file.count
      write_count matching 
    elsif matching
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
    formatted[lnum] || @file.get_line(lnum)
  end

  def show_line_numbers
    @show_line_numbers
  end
end

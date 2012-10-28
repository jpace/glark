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

  def initialize file, options
    @file              = file
    @formatted         = []
    @has_context       = false
    @label             = options.label
    @out               = options.out
    @show_file_name    = options.show_file_names
    @show_line_numbers = options.show_line_numbers
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
    lnums = @file.get_range lnum 
    log { "lnums(#{lnum}): #{lnums}" }

    return unless lnums

    lnums.each do |ln|
      if show_line_numbers
        print_line_number ln 
        if ch && @has_context
          @out.printf "%s ", ch
        end
      end
      line = @formatted[ln] || @file.get_line(ln)
      @out.puts line
    end
  end

  def write_matching from, to
    (from .. to).each do |ln|
      next unless @file.stati[ln] && !@file.is_written?(ln)

      # this used to be conditional on show_break, but no more
      if from > 0 && !@file.stati[ln - 1] && @has_context
        @out.puts "  ---"
      end
      
      print_line ln, @file.stati[ln]  
      @file.set_as_written ln
    end
  end

  def write_nonmatching from, to
    (from .. to).each do |ln|
      if !@file.is_written?(ln) && @file.stati[ln] != ":"
        log { "printing #{ln}" }
        print_line ln 
        @file.set_as_written ln
      end
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

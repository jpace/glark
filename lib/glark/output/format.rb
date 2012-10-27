#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Glark output.

require 'rubygems'
require 'riel'
require 'glark/app/options'
require 'glark/io/file'

class FormatOptions
  attr_accessor :label
  attr_accessor :out
  attr_accessor :show_file_names
  attr_accessor :show_line_numbers

  def initialize 
    @label = nil
    @out = nil
    @show_file_names = nil
    @show_line_numbers = nil
  end
end

class OutputFormat
  include Loggable
  
  attr_reader :formatted, :infile, :show_file_name, :has_context

  def initialize infile, options
    @infile            = infile
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
          unless @infile.stati[ln] == Glark::File::WRITTEN
            # this used to be conditional on show_break, but no more
            if firstline > 0 && !@infile.stati[ln - 1] && has_context
              @out.puts "  ---"
            end
            
            print_line ln, @infile.stati[ln]  

            @infile.stati[ln] = Glark::File::WRITTEN
          end
        end

      end
    else
      firstline = from ? from : 0
      lastline  = to ? to : @infile.get_lines.length - 1
      (firstline .. lastline).each do |ln|
        if @infile.stati[ln] != Glark::File::WRITTEN && @infile.stati[ln] != ":"
          log { "printing #{ln}" }
          print_line ln 
          @infile.stati[ln] = Glark::File::WRITTEN
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

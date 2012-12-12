#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/file_header'
require 'glark/util/highlight'

module Glark; end

module Glark
  module Format
    include Loggable, Highlight
    
    def initialize file, spec
      @file_header = nil        # not nil after file header written
      @fname_highlighter = spec.highlight && spec.file_highlight
      @lnum_highlighter = spec.line_number_highlight

      super
    end

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
        @out.print pad + " " + adorn(@lnum_highlighter, lnumstr) + " "
      else
        super
      end
    end

    def println ln, ch 
      if @show_line_numbers
        print_line_number ln 
      end
      
      if ch && @print_context
        @out.printf "%s ", ch
      end

      line = get_line_to_print ln 
      @out.puts line
    end

    # prints the line, and adjusts for the fact that in our world, lines are
    # 0-indexed, whereas they are displayed as if 1-indexed.
    def print_line lnum, ch = nil 
      lnums = @file.get_region lnum 
      return unless lnums
      lnums.each do |ln|
        println ln, ch 
      end
    end
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/binary_file_summary'
require 'glark/output/context'
require 'glark/output/file_name_only'
require 'glark/output/glark_count'
require 'glark/output/glark_lines'
require 'glark/output/grep_count'
require 'glark/output/grep_lines'
require 'glark/output/unfiltered_lines'

module Glark
  class OutputSpec
    attr_accessor :context           # lines before and after
    attr_accessor :count             # only count the matches
    attr_accessor :file_names_only   # display only the file names
    attr_accessor :filter            # display only matches
    attr_accessor :invert_match      # display non-matching lines
    attr_accessor :label
    attr_accessor :match_limit       # the maximum number of matches to display per file
    attr_accessor :out
    attr_accessor :show_file_names   # display file names
    attr_accessor :show_line_numbers # display numbers of matching lines
    attr_accessor :write_null        # in @file_names_only mode, write '\0' instead of '\n'

    attr_reader :colors
    attr_reader :style               # grep, glark

    def initialize colors
      @colors = colors
      @context = Glark::Context.new
      @count = false
      @file_highlight = nil
      @file_names_only = false
      @filter = true
      @highlight = nil
      @invert_match = false
      @label = nil
      @match_limit = nil
      @out = $stdout
      @show_file_names = nil      # nil == > 1; true == >= 1; false means never
      @show_line_numbers = true
      @style = nil
      @write_null = false

      @output_cls = nil

      self.style = "glark"
    end

    def line_number_highlight
      @colors.line_number_highlight
    end

    def file_highlight 
      @colors.file_highlight
    end

    def highlight
      @colors.text_color_style
    end

    def style= style
      @style = style
      if @style == "glark"
        @colors.text_color_style = "multi"
      elsif @style == "grep"
        @colors.text_color_style = false
        @show_line_numbers = false
        @context.clear
      else
        raise "error: unrecognized style '" + style + "'"
      end
      @output_cls = nil
    end

    def create_output_type file
      output_type_cls.new file, self
    end

    def output_type_cls
      @output_cls ||= if @count
                        if @style == "grep" 
                          Grep::Count
                        else
                          Glark::Count
                        end
                      elsif @file_names_only
                        FileNameOnly
                      elsif !@filter
                        UnfilteredLines
                      elsif @style == "grep"
                        Grep::Lines
                      else
                        Glark::Lines
                      end
    end
    
    def set_file_names_only invert_match
      @file_names_only = true
      @invert_match = invert_match
    end
  end
end

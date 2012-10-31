#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

class OutputOptions
  attr_accessor :context
  attr_accessor :file_highlight
  attr_accessor :filter
  attr_accessor :highlight
  attr_accessor :invert_match
  attr_accessor :label
  attr_accessor :line_number_highlight
  attr_accessor :match_limit
  attr_accessor :out
  attr_accessor :show_file_names
  attr_accessor :show_line_numbers
  attr_accessor :write_null

  def initialize 
    @after = nil
    @before = nil
    @context = nil
    @file_highlight = nil
    @filter = filter
    @highlight = nil
    @invert_match = nil
    @label = nil
    @line_number_highlight = nil
    @match_limit = nil
    @out = nil
    @show_file_names = nil
    @show_line_numbers = nil
    @write_null = nil
  end

  def after
    @context && @context.after
  end

  def before
    @context && @context.before
  end
end

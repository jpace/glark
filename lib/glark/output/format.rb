#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Generic output.

require 'rubygems'
require 'riel'
require 'glark/input/file'
require 'glark/output/formatted'
require 'glark/output/options'

class OutputFormat < FormattedOutputFormat
  def initialize file, fmtopts
    super()

    @file = file
    @invert_match = fmtopts.invert_match
    @label = fmtopts.label
    @match_limit = fmtopts.match_limit
    @out = fmtopts.out
    @show_file_name = fmtopts.show_file_names
    @show_line_numbers = fmtopts.show_line_numbers
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

  def add_match startline, endline
    super()
  end

  def process_match startline, endline, fromline, toline
    add_match startline, endline
    return at_match_limit?
  end
end

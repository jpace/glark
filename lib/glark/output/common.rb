#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Generic output.

require 'glark/io/file/file'
require 'glark/output/formatted'

class Common < Formatted
  def initialize file, spec
    super()

    @file = file
    @invert_match = spec.invert_match
    @label = spec.label
    @match_limit = spec.match_limit
    @out = spec.out
    @show_file_name = spec.show_file_names
    @show_line_numbers = spec.show_line_numbers
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

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/results/format'

class CountFormat < OutputFormat
  def display_matches?
    false
  end

  def write_count ct
    if @show_file_name
      print_file_name
    end
    print_count ct
  end

  def process_end lnum
    if @invert_match
      write_count @file.get_lines.size - @count
    elsif matched?
      write_count @count
    end
  end
end

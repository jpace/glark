#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/format'

class CountFormat < OutputFormat
  def initialize file, fmtopts
    super
    @count = 0
  end

  def add_match
    @count += 1
  end

  def write_count matching = true 
    print_file_name
    ct = matching ? @count : @file.get_lines.size - @count
    print_count ct
  end

  def print_file_name
  end

  def print_count ct
  end    
end

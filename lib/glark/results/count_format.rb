#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/results/format'

class CountFormat < OutputFormat
  def write_count matching = true 
    if @show_file_name
      print_file_name
    end
    ct = matching ? @count : @file.get_lines.size - @count
    print_count ct
  end

  def print_file_name
  end

  def print_count ct
  end    

  def process_end matched, lnum
    info "matched: #{matched}".on_red
    if @invert_match
      write_count false
    elsif matched
      write_count true
    end
  end
end

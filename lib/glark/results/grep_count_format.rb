#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/results/count_format'

class GrepCountFormat < CountFormat
  def write_count matching = true
    print_file_name
    ct = matching ? @count : @file.get_lines.size - @count
    puts ct
  end

  def print_file_name
    if @show_file_name
      fname = @label || @file.fname
      @out.print fname, ":"
    end
  end

  def print_count ct
    puts ct
  end
end

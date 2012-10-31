#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/lines'
require 'glark/output/glark_format'

class UnfilteredLines < Lines
  include Glark::Format
  
  def display_matches?
    false
  end

  def process_end lnum
    show_file_header
    write_all
  end

  def write_all
    show_file_header
    (0 ... @file.get_lines.length).each do |ln|
      print_line ln  
    end
  end
end

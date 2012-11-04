#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/common'

class BinaryFile < Common
  def display_matches?
    false
  end

  def process_end lnum
    if matched?
      @out.puts "Binary file " + @file.fname + " matches"
    end
  end
end

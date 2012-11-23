#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/common'

class BinaryFileSummary < Common
  def display_matches?
    false
  end

  def process_end lnum
    if matched?
      @out.puts "Binary file " + @file.fname.to_s + " matches"
    end
  end
end

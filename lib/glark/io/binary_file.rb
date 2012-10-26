#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/io/file'

class Glark::BinaryFile < Glark::File
  def write_matches matching, from, to
    if count
      @output.write_count matching
    else
      puts "Binary file " + @fname + " matches"
    end
  end
end

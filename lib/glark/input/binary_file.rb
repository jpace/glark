#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/file'

### $$$ binary files are broken with 1.9.2:
class Glark::BinaryFile < Glark::File
  def process_end from, to
    if matched?
      @out.puts "Binary file " + @fname + " matches"
    end
  end
end
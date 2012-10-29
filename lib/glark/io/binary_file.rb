#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/io/file'

### $$$ binary files are broken with 1.9.2:
class Glark::BinaryFile < Glark::File
  def write_matches matching, from, to
    if @count
      @output.write_count matching
    else
      @out.puts "Binary file " + @fname + " matches"
    end
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/common'

class FileNameOnly < Common
  def initialize fname, spec
    super
    @write_null = spec.write_null
  end

  def at_match_limit?
    @count > 0
  end

  def display_matches?
    false
  end

  def print_file_name
    if @write_null
      @out.print @file.fname
      @out.print "\0"
    else
      @out.puts @file.fname
    end
  end

  def process_end lnum
    if matched? != @invert_match
      print_file_name
    end
  end
end

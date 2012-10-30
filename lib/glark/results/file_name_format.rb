#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/results/format'

class FileNameFormat < OutputFormat
  def initialize fname, fmtopts
    super
    @write_null = fmtopts.write_null
  end

  def at_match_limit?
    @count > 0
  end

  def display_matches?
    false
  end

  def print_only_file_name
    if @write_null
      @out.print @file.fname + "\0"
    else
      @out.puts @file.fname
    end
  end

  def process_end lnum
    if matched? != @invert_match
      print_only_file_name
    end
  end
end

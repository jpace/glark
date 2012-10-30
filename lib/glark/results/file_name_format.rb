#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/results/format'

class FileNameFormat < OutputFormat
  def initialize fname, fmtopts
    super
    @write_null = fmtopts.write_null
  end

  def print_only_file_name
    if @write_null
      @out.print @file.fname + "\0"
    else
      @out.puts @file.fname
    end
  end

  def process_end matched, lnum
    info "matched: #{matched}".on_red
    if matched != @invert_match
      print_only_file_name
    end
  end

  def mark_as_match startline, endline
    add_match
    # the superclass is storing the status; we don't need that.
  end
end

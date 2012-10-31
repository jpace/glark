#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/count'

class GlarkCount < Count
  def initialize fname, fmtopts
    super
    @fname_highlighter = fmtopts.highlight && fmtopts.file_highlight
  end

  def print_file_name
    file_header = FileHeader.new displayed_name, @fname_highlighter
    file_header.print @out
  end

  def print_count ct
    @out.puts "    " + ct.to_s
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/count'

module Glark
  class Count < ::Count
    def initialize fname, spec
      super
      @fname_highlighter = spec.highlight && spec.file_highlight
    end

    def print_file_name
      file_header = FileHeader.new displayed_name, @fname_highlighter
      file_header.print @out
    end

    def print_count ct
      @out.puts "    " + ct.to_s
    end
  end
end

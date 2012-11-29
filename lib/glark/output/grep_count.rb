#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/count'

module Grep
  class Count < ::Count
    def print_file_name
      fname = displayed_name
      @out.print fname, ":"
    end

    def print_count ct
      @out.puts ct
    end
  end
end

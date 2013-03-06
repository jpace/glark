#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/util/highlight'

class FileHeader
  include Highlight
  
  def initialize name, highlighter
    @name = name
    @highlighter = highlighter
  end

  def print out
    name = @name.to_s
    fname = @highlighter ? adorn(@highlighter, name) : name
    out.puts fname
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

class FileHeader
  include Loggable
  
  def initialize name, highlighter
    @name = name
    @highlighter = highlighter
  end

  def print out
    fname = @name
    fname = @highlighter.highlight(fname.to_s) if @highlighter
    out.puts fname.to_s
  end
end

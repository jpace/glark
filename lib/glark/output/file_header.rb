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
    name = @name.to_s
    fname = @highlighter ? @highlighter + name + Text::Color::RESET : name
    out.puts fname
  end
end

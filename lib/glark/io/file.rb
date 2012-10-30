#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel'
require 'glark/io/lines'

module Glark; end

# A thing that can be grepped (er, glarked).
class Glark::File
  include Loggable

  attr_reader :fname
  
  def initialize fname, io
    @fname = fname
    
    if $/ == "\n"
      @lines = Glark::LinesCR.new fname, io
    else
      @lines = Glark::LinesNonCR.new fname, io
      info "@lines: #{@lines}".on_cyan
    end
  end
  
  def linecount
    @lines.count
  end

  def each_line &blk
    @lines.each_line(&blk)
  end

  # Returns the lines for this file, separated by end of line sequences.
  def get_lines
    @lines.get_lines
  end
  
  # Returns the given line for this file. For this method, a line ends with a
  # CR, as opposed to the "lines" method, which ends with $/.
  def get_line lnum
    @lines.get_line lnum
  end

  # returns the range that is represented by the region number
  def get_range rnum
    @lines.get_range rnum
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Output that has (possibly) been reformatted, i.e., highlighting of regular
# expressions.

require 'glark/input/file'
require 'glark/output/results'

class FormattedOutputFormat < Results
  attr_reader :formatted

  def initialize
    super
    @formatted = []
  end

  def get_line_to_print lnum 
    @formatted[lnum] || @file.get_line(lnum)
  end
end

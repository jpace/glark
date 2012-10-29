#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/results/glark_format'

# not supported yet; will be matches stored instead of written to stdout.
class GlarkMatchList < GlarkOutputFormat
  attr_reader :matches

  def initialize file, show_file_names 
    super
    @matches = Array.new
  end

  def write_matches matching, from, to 
    stack "matching: #{matching}"
    from.upto(to) do |line|
      @matches[line] = true
    end
    log { "matches: #{@matches}" }
  end
end

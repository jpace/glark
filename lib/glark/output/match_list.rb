#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# not yet supported; will be matches stored instead of written to stdout.
class GlarkMatchList
  attr_reader :matches

  def initialize file, show_file_names 
    super
    @matches = Array.new
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel'
require 'glark/input/options'

module Glark; end

# A set of files and directories.

class Glark::FileSet < Array
  include Loggable
  
  def initialize fnames, input_options, &blk
    @input_options = input_options

    if @input_options.split_as_path
      fnames = fnames.collect { |f| f.split File::PATH_SEPARATOR  }.flatten
    end

    @all = Array.new

    fnames.each do |fname|
      # pn = Pathname.new fname
      # if pn.file?
      # next if skipped? fname
      @all << fname
    end

    super @all
  end

  def skipped_file? fname
    @input_options.skipped? fname
  end
end

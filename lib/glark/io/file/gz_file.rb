#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/io/file/file'
require 'zlib'

class Glark::GzFile < Glark::File
  def initialize fname, &blk
    Zlib::GzipReader.open(fname) do |gz|
      super fname, gz, nil
      blk.call [ self, gz ]
    end
  end
end

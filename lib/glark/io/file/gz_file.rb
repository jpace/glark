#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/io/file/file'
require 'zlib'

class Glark::GzFile < Glark::File
  def initialize fname, &blk
    if blk
      Zlib::GzipReader.open(fname) do |gz|
        super fname, gz, nil
        blk.call [ self, gz ]
      end
    else
      gz = Zlib::GzipReader.new fname
      super fname, gz, nil
    end
  end
end

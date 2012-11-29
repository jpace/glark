#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/io/file/file'
require 'zlib'

module Glark
  class GzFile < Glark::File
    def initialize fname, range, &blk
      if blk
        Zlib::GzipReader.open(fname) do |gz|
          super fname, gz, range
          blk.call [ self, gz ]
        end
      else
        gz = Zlib::GzipReader.new fname
        super fname, gz, range
      end
    end
  end
end

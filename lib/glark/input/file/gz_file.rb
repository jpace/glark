#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'zlib'

require 'glark/input/file/file'

class Glark::GzFile < Glark::File
  def initialize fname, &blk
    Zlib::GzipReader.open(fname) do |gz|
      info "gz: #{gz}".red
      super fname, gz, nil
      blk.call self
    end
  end
end

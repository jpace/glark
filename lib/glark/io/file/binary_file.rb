#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/file'

class Glark::BinaryFile < Glark::File
  def initialize fname
    file = ::File.new fname
    file.binmode            # for MSDOS/WinWhatever
    super fname, file, nil
  end
end

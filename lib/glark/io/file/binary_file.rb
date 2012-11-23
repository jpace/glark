#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/file'

class Glark::BinaryFile < Glark::File
  def initialize fname
    file = ::File.new fname
    file.binmode            # for MSDOS/WinWhatever
    super fname, file, nil
  end

  def search_as_binary expr, output_opts
    output_type = BinaryFileSummary.new self, output_opts
    search expr, output_type
  end
end

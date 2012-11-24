#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/file'
require 'glark/io/file/archive_file'

class Glark::TarFile < Glark::ArchiveFile
  def initialize fname, range, io = nil, &blk
    super fname, range

    # Given that this is a gem, I'm not sure if it is installed with other
    # package managers. So the require is down here, used only if needed.
    
    # module Gem::Package is declared in 'rubygems/package', not in
    # .../tar_reader.
    require 'rubygems/package'
    require 'rubygems/package/tar_reader'
    @io = io
  end

  def get_reader 
    io = @io || ::File.new(@fname)
    Gem::Package::TarReader.new io
  end

  def entry_name entry
    entry.full_name
  end

  def read entry
    entry.read
  end
end

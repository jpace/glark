#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/input/file/file'

class Glark::TarFile
  def initialize fname, &blk
    # Given that this is a gem, I'm not sure if it is installed with other
    # package managers. So the require is down here, used only if needed.
    
    # module Gem::Package is declared in 'rubygems/package', not in
    # .../tar_reader.
    require 'rubygems/package'
    require 'rubygems/package/tar_reader'

    @fname = fname
  end

  def each_file &blk
    f = ::File.new @fname
    tr = Gem::Package::TarReader.new f

    tr.each do |entry|
      if entry.file?
        blk.call entry
      end
    end
  end

  def each_as_list &blk
  end
end

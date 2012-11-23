#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/input/file/file'

class Glark::ZipFile
  include Loggable
  
  def initialize fname, &blk
    # Same caveat as ZipFile. Given that this is a gem, I'm not sure if it is
    # installed with other package managers. So the require is down here, used
    # only if needed.

    begin
      require 'zip/zip'
    end
    @fname = fname
  end

  def each_file &blk
    @zipfile = Zip::ZipFile.new @fname
    @zipfile.each do |entry|
      if entry.file?
        blk.call entry
      end
    end
  end

  def read entry
    @zipfile.read entry
  end

  def list
    contents = Array.new
    each_file do |entry|
      contents << entry.name
    end
    contents
  end
end

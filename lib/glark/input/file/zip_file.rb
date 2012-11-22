#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/input/file/file'

class Glark::ZipFile
  include Loggable
  
  def initialize fname, &blk
    # Same caveat as ZipFile. Given that this is a gem, I'm not sure if it is
    # installed with other package managers. So the require is down here, used
    # only if needed.
    
    require 'zip/zip'
    @fname = fname
  end

  def each_file &blk
    zipfile = Zip::ZipFile.new @fname
    info "zipfile: #{zipfile}".red

    zipfile.each do |entry|
      info "entry: #{entry}".red
      info "entry: #{entry.name}".red
      if entry.file?
        blk.call entry
      end
    end
  end
end

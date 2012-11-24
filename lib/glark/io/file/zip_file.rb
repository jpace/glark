#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/archive_file'

class Glark::ZipFile < Glark::ArchiveFile
  include Loggable
  
  def initialize fname, range, &blk
    super fname, range
    
    # Same caveat as ZipFile. Given that this is a gem, I'm not sure if it is
    # installed with other package managers. So the require is down here, used
    # only if needed.

    begin
      require 'zip/zip'
    rescue LoadError => e
      msg = "error loading zip gem: #{e}\n"
      msg << "to install this dependency, run 'gem install rubyzip'"
      info "msg: #{msg}".on_red
      raise msg
    end
  end

  def get_reader 
    @zipfile = Zip::ZipFile.new @fname
  end

  def read entry
    @zipfile.read entry
  end

  def entry_name entry
    entry.name
  end
end

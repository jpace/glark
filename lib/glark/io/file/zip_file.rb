#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'
require 'glark/io/file/archive_file'

module Glark
  class ZipFile < ArchiveFile
    include Logue::Loggable
    
    def initialize fname, range, &blk
      super fname, range
      
      check_rubyzip
    end

    def get_reader 
      @zipfile = Zip::File.new @fname
    end

    def read entry
      @zipfile.read entry
    end

    def entry_name entry
      entry.name
    end

    def check_rubyzip
      check_rubyzip_exists
      check_rubyzip_version
    end

    def check_rubyzip_exists
      # Given that this is a gem, I'm not sure if it is installed with other
      # package managers. So the require is down here, used only if needed.
      begin
        require 'zip'
      rescue LoadError => e
        msg = "error loading zip gem: #{e}\n"
        msg << "to install this dependency, run 'gem install rubyzip'"
        info Rainbow::Presenter.new("msg: #{msg}").color(:red)
        raise msg
      end
      check_rubyzip_version
    end

    def check_rubyzip_version
      require 'zip/version'
      reqver = '1.1.4'
      reqnum = version_to_number reqver
      currnum = version_to_number Zip::VERSION
      if currnum < reqnum
        msg = "error: support for zip files requires rubyzip version >= #{reqver}; current version is #{Zip::VERSION}"
        info Rainbow::Presenter.new("msg: #{msg}").color(:red)
        raise msg
      end        
    end

    def version_to_number ver
      vernums = ver.split('.')
      num = vernums.inject(0) { |s, n| 1000 * s + n.to_i }
    end
  end
end

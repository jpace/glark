#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/gz_file'
require 'glark/io/file/tar_file'

module Glark
  class TarGzFile
    include Loggable
    
    def initialize fname, range
      @fname = fname
      @range = range
    end

    def list
      contents = Array.new
      each_file do |entry|
        contents << entry.full_name
      end
      contents
    end

    def run_search &blk
      # a glitch with zlib results in a warning ("attempt to close unfinished
      # zstream; reset forced.") for some tarballs, so we turn off warnings for
      # a moment:
      $-w = false
      
      Zlib::GzipReader.open(@fname) do |gzio|
        tarfile = Glark::TarFile.new @fname, @range, gzio
        blk.call tarfile
      end

      $-w = true
    end

    def search_list expr, output_cls, output_opts
      run_search do |tarfile|
        tarfile.search_list expr, output_cls, output_opts
      end
    end

    def search expr, output_type_cls, output_opts
      matched = nil
      run_search do |tarfile|
        matched = tarfile.search(expr, output_type_cls, output_opts) || matched
      end
      matched
    end
  end
end

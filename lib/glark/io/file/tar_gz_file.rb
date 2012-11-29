#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/gz_file'
require 'glark/io/file/tar_file'

module Glark
  class TarGzFile
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

    def search_list expr, output_cls, output_opts
      Zlib::GzipReader.open(@fname) do |gzio|
        tarfile = Glark::TarFile.new @fname, @range, gzio
        tarfile.search_list expr, output_cls, output_opts
      end
    end

    def search expr, output_type_cls, output_opts
      matched = nil
      Zlib::GzipReader.open(@fname) do |gzio|
        tarfile = Glark::TarFile.new @fname, @range, gzio
        matched = tarfile.search(expr, output_type_cls, output_opts) || matched
      end
      matched
    end
  end
end

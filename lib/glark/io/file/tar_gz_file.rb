#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/gz_file'
require 'glark/io/file/tar_file'

class Glark::TarGzFile
  def initialize fname
    @fname = fname
  end

  def list
    contents = Array.new
    each_file do |entry|
      contents << entry.full_name
    end
    contents
  end

  def search_list expr, output_cls, output_opts, range
    Zlib::GzipReader.open(@fname) do |gzio|
      tarfile = Glark::TarFile.new @fname, gzio
      tarfile.search_list expr, output_cls, output_opts, range
    end
  end
end

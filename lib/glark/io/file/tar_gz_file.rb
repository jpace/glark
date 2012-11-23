#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/gz_file'
require 'glark/io/file/tar_file'

class Glark::TarGzFile < Glark::GzFile
  def initialize fname
    super fname do |file, io|
      @io = io.read
    end
  end

  def list
    contents = Array.new
    each_file do |entry|
      contents << entry.full_name
    end
    contents
  end

  def search_list expr, output_cls, output_opts, range
    tarfile = Glark::TarFile.new @fname, StringIO.new(@io)
    tarfile.search_list expr, output_cls, output_opts, range
  end
end

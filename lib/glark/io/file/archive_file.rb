#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/file'

class Glark::ArchiveFile
  def initialize fname
    @fname = fname
  end

  def search_list expr, output_cls, output_opts, range
    contents = StringIO.new list.collect { |x| x + "\n" }.join('')
    contents.rewind

    file = Glark::File.new @fname, contents, range
    output_type = output_cls.new file, output_opts
    file.search expr, output_type
  end
end

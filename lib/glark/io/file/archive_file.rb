#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/file'

class Glark::ArchiveFile
  def initialize fname, range
    @fname = fname
    @range = range
  end

  def search_list expr, output_cls, output_opts
    contents = StringIO.new list.collect { |x| x + "\n" }.join('')
    contents.rewind

    file = Glark::File.new @fname, contents, @range
    output_type = output_cls.new file, output_opts
    file.search expr, output_type
  end

  def list
    contents = Array.new
    each_file do |entry|
      contents << entry_name(entry)
    end
    contents
  end

  def each_file &blk
    reader = get_reader
    reader.each do |entry|
      if entry.file?
        blk.call entry
      end
    end
    reader.close
  end

  def search_archive_file expr, entry, output_type_cls, output_opts
    name = entry_name entry
    contents = StringIO.new(read(entry))

    file = Glark::File.new name + " (in #{@fname})", contents, @range
    output = output_type_cls.new file, output_opts
    file.search expr, output
  end

  def read entry
    entry.read
  end

  def search expr, output_type_cls, output_opts
    matched = nil
    each_file do |entry|
      matched = search_archive_file(expr, entry, output_type_cls, output_opts) || matched
    end
    matched
  end
end

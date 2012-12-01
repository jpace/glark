#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/io/file/file'

module Glark
  class ArchiveFile
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
      each do |entry|
        contents << entry_name(entry)
      end
      contents
    end

    def each &blk
      reader = get_reader
      reader.each do |entry|
        blk.call entry
      end
      reader.close
    end

    def search_archive_file expr, entry, output_type_cls, output_opts
      name = entry_name entry
      data = read entry
      contents = StringIO.new data
      
      file = Glark::File.new name + " (in #{@fname})", contents, @range
      output = output_type_cls.new file, output_opts
      file.search expr, output
    end

    def read entry
      entry.read
    end

    def search expr, output_type_cls, output_opts
      matched = nil
      each do |entry|
        # a glitch with zlib doesn't seem to recognize some tarball entries
        # (with entry.header.typeflag == "") as being a file, so we test for
        # directory:
        next if entry.directory?
        matched = search_archive_file(expr, entry, output_type_cls, output_opts) || matched
      end
      matched
    end
  end
end

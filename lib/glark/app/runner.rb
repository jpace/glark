#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel'
require 'glark/app/options'
require 'glark/io/file/binary_file'
require 'glark/io/file/gz_file'
require 'glark/io/file/tar_file'
require 'glark/io/file/tar_gz_file'
require 'glark/io/file/zip_file'

$stdout.sync = true             # unbuffer
$stderr.sync = true             # unbuffer

module Glark; end

# The main processor.
class Glark::Runner
  include Loggable

  GZ_RE = Regexp.new '\.gz$'
  TAR_GZ_RE = Regexp.new '\.(?:tgz|tar\.gz)$'
  TAR_RE = Regexp.new '\.tar$'
  ZIP_RE = Regexp.new '\.(?:zip|jar)$'
  
  attr_reader :exit_status
  
  def initialize opts, files
    @opts = opts
    @expr = opts.expr
    @searched_files = Array.new          # files searched, so we don't cycle through links

    @exclude_matching = @opts.input_options.exclude_matching

    @range = @opts.range
    @output_opts = @opts.output_options
    @invert_match = @output_opts.invert_match

    # 0 == matches, 1 == no matches, 2 == error
    @exit_status = @invert_match ? 0 : 1

    @output_type_cls = @output_opts.output_type_cls
    
    @opts.files.each do |type, file|
      search type, file
    end
  end

  def search_file file, output_type_cls = @output_type_cls
    output_type = output_type_cls.new file, @output_opts
    update_status file.search @expr, output_type
  end

  def update_status matched
    if matched
      @exit_status = @invert_match ? 1 : 0
    end
  end

  def search_text fname
    io = fname == "-" ? $stdin : File.new(fname)
    file = Glark::File.new fname, io, @range
    search_file file
  end

  def search_binary fname
    file = Glark::BinaryFile.new fname
    update_status file.search_as_binary @expr, @output_opts
  end

  def search_read_tar_gz_file fname
    Glark::GzFile.new(fname) do |file, io|
      tarfile = Glark::TarFile.new fname, io
      search_read_tar_entries fname, tarfile
    end
  end

  def search_read_tar_file fname
    tarfile = Glark::TarFile.new fname
    search_read_tar_entries fname, tarfile
  end

  def search_read_archive_file fname, name, contents
    file = Glark::File.new name + " (in #{fname})", contents, nil
    search_file file
  end

  def search_read_tar_entries fname, tarfile
    @output_opts.show_file_names = true
    tarfile.each_file do |entry|
      contents = StringIO.new entry.read
      search_read_archive_file fname, entry.full_name, contents
    end
  end

  def search_read_gz_file fname
    # gzfile = Glark::GzFile.new fname
    # output_type = @output_type_cls.new gzfile, @output_opts
    # update_status gzfile.search @expr, output_type
    Glark::GzFile.new(fname) do |file, io|
      search_file file
    end
  end

  def search_read_zip_entries fname, zipfile
    @output_opts.show_file_names = true
    zipfile.each_file do |entry|
      contents = StringIO.new zipfile.read(entry)
      search_read_archive_file fname, entry.name, contents
    end
  end

  def search_read_zip_file fname
    @output_opts.show_file_names = true
    zipfile = Glark::ZipFile.new fname
    search_read_zip_entries fname, zipfile
  end

  def search_read fname
    fstr = fname.to_s
    
    case
    when TAR_GZ_RE.match(fstr)
      search_read_tar_gz_file fname
    when GZ_RE.match(fstr)
      search_read_gz_file fname
    when TAR_RE.match(fstr)
      search_read_tar_file fname
    when ZIP_RE.match(fstr)
      search_read_zip_file fname
    else
      raise "file '#{fname}' does not have a handled extension"
    end
  end

  def search_list fname
    fstr = fname.to_s

    file = nil
    case
    when TAR_RE.match(fstr)
      file = Glark::TarFile.new fname
    when ZIP_RE.match(fstr)
      file = Glark::ZipFile.new fname
    when TAR_GZ_RE.match(fstr)
      file = Glark::TarGzFile.new fname
    else
      raise "file '#{fname}' does not have a handled extension"
    end

    update_status file.search_list(@expr, @output_type_cls, @output_opts, @range)
  end
  
  def search type, name
    if @exclude_matching
      expr = @opts.expr
      return if expr.respond_to?(:re) && expr.re.match(name.to_s)
    end
    
    if name == "-" 
      write "reading standard input..."
      search_text "-"
    else
      case type
      when FileType::BINARY
        search_binary name 
      when FileType::TEXT
        search_text name 
      when :decompress, :read
        search_read name 
      when :list
        search_list name 
      else
        raise "type unknown: file: #{name}; type: #{type}"
      end
    end
  end
end

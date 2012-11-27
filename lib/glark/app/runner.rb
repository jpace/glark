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
    @expr = opts.match_spec.expr
    @searched_files = Array.new          # files searched, so we don't cycle through links

    @exclude_matching = @opts.input_spec.exclude_matching

    @range = @opts.input_spec.range
    @output_opts = @opts.output_options
    @invert_match = @output_opts.invert_match

    # 0 == matches, 1 == no matches, 2 == error
    @exit_status = @invert_match ? 0 : 1

    @output_type_cls = @output_opts.output_type_cls
    
    @opts.fileset.each do |type, file|
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

  def search_text fname, io
    file = Glark::File.new fname, io, @range
    search_file file
  end

  def search_binary fname
    file = Glark::BinaryFile.new fname
    update_status file.search_as_binary @expr, @output_opts
  end

  def search_read_archive_file fname, cls
    @output_opts.show_file_names = true
    file = cls.new fname, @range
    update_status file.search @expr, @output_type_cls, @output_opts
  end

  def search_read fname
    fstr = fname.to_s
    
    case
    when TAR_GZ_RE.match(fstr)
      search_read_archive_file fname, Glark::TarGzFile
    when GZ_RE.match(fstr)
      search_file Glark::GzFile.new(fname, @range)
    when TAR_RE.match(fstr)
      search_read_archive_file fname, Glark::TarFile
    when ZIP_RE.match(fstr)
      search_read_archive_file fname, Glark::ZipFile
    else
      raise "file '#{fname}' does not have a handled extension"
    end
  end

  def search_list fname
    fstr = fname.to_s

    cls = case
          when TAR_RE.match(fstr)
            Glark::TarFile
          when ZIP_RE.match(fstr)
            Glark::ZipFile
          when TAR_GZ_RE.match(fstr)
            Glark::TarGzFile
          else
            raise "file '#{fname}' does not have a handled extension"
          end

    file = cls.new fname, @range

    update_status file.search_list(@expr, @output_type_cls, @output_opts)
  end
  
  def search type, name
    if @exclude_matching
      expr = @opts.match_spec.expr
      return if expr.respond_to?(:re) && expr.re.match(name.to_s)
    end
    
    if name == "-" 
      write "reading standard input..."
      search_text name, $stdin
    else
      case type
      when :binary
        search_binary name 
      when :text
        search_text name, File.new(name)
      when :read
        search_read name 
      when :list
        search_list name 
      else
        raise "type unknown: file: #{name}; type: #{type}"
      end
    end
  end
end

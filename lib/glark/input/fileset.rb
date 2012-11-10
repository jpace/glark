#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel'
require 'glark/input/options'

module Glark; end

# Files and directories. And standard output, just for fun.

class Glark::FileSet
  include Loggable, Enumerable
  
  def initialize fnames, input_options, &blk
    super()

    info "fnames: #{fnames}".yellow

    @input_options = input_options
    @maxdepth = @input_options.directory == "list" ? 1 : nil
    @bin_as_text = @input_options.binary_files == "binary"
    @split_as_path = @input_options.split_as_path
    @skip_dirs = @input_options.directory == "skip"

    @files = Array.new
    
    if fnames.size == 0
      @files << '-'
    else
      add_files fnames
    end
    
    info "@files: #{@files.inspect}"

    # to keep from cycling through links:
    @yielded_files = nil
  end

  def size
    @files.size
  end

  def one_file?
    return false if @files.size > 1
    first = @files.first
    first.to_s != '-' && first.file?
  end

  def add_files fnames
    fnames.each do |fname|
      info "fname: #{fname}".yellow
      if @split_as_path
        add_as_path fname
      else
        add_fd fname
      end
    end      
  end

  def add_as_path path
    path.to_s.split(File::PATH_SEPARATOR).each do |element|
      info "element: #{element}"
      add_fd element
    end
  end

  def add_fd fname
    pn = Pathname.new fname
    info "pn: #{pn}"
    next if pn.file? && skipped?(pn)
    @files << pn
  end

  def skipped? pn
    @input_options.skipped? pn
  end

  def stdin?
    size == 1 && @files[0] == '-'
  end

  def directory? idx
    pn = @files[idx]
    pn && FileType.type(pn) == FileType::DIRECTORY
  end

  def each &blk
    @yielded_files = Array.new

    depth = 0

    info "blk: #{blk}".on_red
    (0 ... @files.size).each do |idx|
      pn = @files[idx]
      info "pn: #{pn}".yellow
      type = FileType.type pn.to_s
      info "type: #{type}".yellow

      if stdin?
        blk.call [ :text, '-' ]
        next
      end

      handle_pathname pn, depth, &blk
    end
  end

  def handle_pathname pn, depth, &blk
    info "pn: #{pn}".red

    if pn.directory?
      handle_directory pn, depth, &blk
    elsif pn.file?
      handle_file pn, &blk
    else
      write "unknown file type: #{pn}"
    end
  end

  def handle_directory pn, depth, &blk
    info "pn: #{pn}".cyan

    return if @skip_dirs

    if @maxdepth.nil? || depth < @maxdepth
      begin
        pn.children.sort.each do |entry|
          next if @yielded_files.include?(entry)
          @yielded_files << entry
          handle_pathname entry, depth + 1, &blk
        end
      rescue Errno::EACCES => e
        write "directory not readable: #{pn}"
      end
    end
  end

  def handle_file pn, &blk
    return if skipped? pn

    unless pn.readable?
      log { "skipping unreadable: #{pn}" }
      return
    end

    type = FileType.type pn.to_s
    info "type: #{type}".red
    case type
    when FileType::TEXT
      handle_text pn, &blk
    when FileType::BINARY
      handle_binary pn, &blk
    when FileType::NONE
      write "no such file: #{pn}"
    when FileType::UNKNOWN
      write "unknown file type: #{pn}"
    end
  end

  def handle_text pn, &blk
    return if skipped? pn

    blk.call [ FileType::TEXT, pn ]
  end

  def handle_binary pn, &blk
    return if skipped? pn

    type = @bin_as_text ? FileType::BINARY : FileType::TEXT
    blk.call [ type, pn ]
  end
end

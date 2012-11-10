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

  DEPTH_RE = Regexp.new '\.\.\.(\d*)$'
  INFINITY = Object.new
  
  def initialize fnames, input_options, &blk
    @input_options = input_options
    @maxdepth = @input_options.directory == "list" ? 0 : nil
    @bin_as_text = @input_options.binary_files == "binary"
    @split_as_path = @input_options.split_as_path
    @skip_dirs = @input_options.directory == "skip"
    @dir_to_maxdepth = Hash.new

    @files = Array.new
    
    if fnames.size == 0
      @files << '-'
    else
      add_files fnames
    end    
  end

  def one_file?
    return false if @files.size > 1
    first = @files.first
    first.to_s != '-' && first.file?
  end

  def add_files fnames
    fnames.each do |fname|
      if @split_as_path
        add_as_path fname
      else
        add_fd fname
      end
    end      
  end

  # this is a path in the form /usr/bin:/home/me/projects
  def add_as_path path
    path.to_s.split(File::PATH_SEPARATOR).each do |element|
      add_fd element
    end
  end

  def add_fd fname
    pn = nil

    if md = DEPTH_RE.match(fname)
      depth = md[1].empty? ? INFINITY : md[1].to_i
      fname.sub! DEPTH_RE, ''
      fname = '.' if fname.empty?
      pn = Pathname.new fname
      @dir_to_maxdepth[pn] = depth
    else
      pn = Pathname.new fname
    end

    next if pn.file? && skipped?(pn)
    @files << pn
  end

  def skipped? pn
    @input_options.skipped? pn
  end

  def stdin?
    @files.size == 1 && @files[0] == '-'
  end

  def directory? idx
    pn = @files[idx]
    pn && FileType.type(pn) == FileType::DIRECTORY
  end

  def each &blk
    # to keep from cycling through links:
    @yielded_files = Array.new

    depth = 0

    (0 ... @files.size).each do |idx|
      pn = @files[idx]
      type = FileType.type pn.to_s

      if stdin?
        blk.call [ :text, '-' ]
        next
      end

      dirmax = @dir_to_maxdepth[pn] || @maxdepth
      handle_pathname pn, dirmax, &blk
    end
  end

  def handle_pathname pn, depth, &blk
    if pn.directory?
      handle_directory pn, depth, &blk
    elsif pn.file?
      handle_file pn, &blk
    else
      write "unknown file type: #{pn}"
    end
  end

  def handle_directory pn, depth, &blk
    return if @skip_dirs

    unless pn.readable?
      write "directory not readable: #{pn}"
      return
    end
    
    if depth != INFINITY && depth && depth < 0
      return
    end

    subdepth = depth == INFINITY ? INFINITY : depth && depth - 1

    pn.children.sort.each do |entry|
      next if @yielded_files.include?(entry)
      @yielded_files << entry
      handle_pathname entry, subdepth, &blk
    end
  end

  def handle_file pn, &blk
    return if skipped? pn

    unless pn.readable?
      log { "skipping unreadable: #{pn}" }
      return
    end

    type = FileType.type pn.to_s
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

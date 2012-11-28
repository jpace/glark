#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel'
require 'glark/util/io/depth'

module Glark; end

# Files and directories. And standard input, just for fun.

class Glark::FileSet
  include Loggable, Enumerable

  attr_reader :files

  DEPTH_RE = Regexp.new '\.\.\.(\d*)$'
  INFINITY = Object.new
  
  def initialize fnames, args
    @maxdepth = args[:maxdepth] || nil
    @binary_files = args[:binary_files] || 'skip'
    @dir_criteria = args[:dir_criteria]
    @file_criteria = args[:file_criteria]
    @skip_dirs = args[:skip_dirs]
    @split_as_path = args[:split_as_path]

    @dir_to_maxdepth = Hash.new
    @files = Array.new
    
    if fnames.size == 0
      @files << '-'
    else
      add_files fnames
    end
  end

  def size
    @files.size
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

    return if pn.file? && file_skipped?(pn)
    @files << pn
  end

  def file_skipped? pn
    @file_criteria.skipped? pn
  end

  def directory_skipped? pn, depth
    return true if @skip_dirs
    return true if depth != INFINITY && depth && depth < 0
    @dir_criteria.skipped? pn
  end

  def stdin?
    @files.size == 1 && @files.first == '-'
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
      
      unless pn.readable?
        write "directory not readable: #{pn}"
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
    return if directory_skipped? pn, depth
    
    subdepth = depth == INFINITY ? INFINITY : depth && depth - 1

    pn.children.sort.each do |entry|
      next if @yielded_files.include?(entry)
      if entry.file?
        type = FileType.type entry.to_s
        next if type == FileType::BINARY
      end
      @yielded_files << entry
      handle_pathname entry, subdepth, &blk
    end
  end

  def handle_file pn, &blk
    return if file_skipped? pn

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
    return if file_skipped? pn
    blk.call [ :text, pn ]
  end

  def handle_binary pn, &blk
    return if file_skipped? pn

    type = case @binary_files
           when 'binary'
             :binary
           when 'skip', 'without-match'
             return
           when 'decompress', 'read'
             :read
           when 'list'
             :list
           else
             :text
           end
    blk.call [ type, pn ]
  end
end

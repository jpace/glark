#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel'
require 'glark/input/options'

module Glark; end

# Files and directories. And standard output, just for fun.

class Glark::FileSet < Array
  include Loggable
  
  def initialize fnames, input_options, &blk
    super()

    info "fnames: #{fnames}".yellow

    @input_options = input_options

    if @input_options.split_as_path
      fnames = fnames.collect { |f| f.split File::PATH_SEPARATOR  }.flatten
    end

    if fnames.size == 0
      fnames = %w{ - }
    end

    fnames.each do |fname|
      pn = Pathname.new fname
      next if pn.file? && skipped?(fname)
      self << fname
    end

    # to keep from cycling through links:
    @yielded_files = nil
  end

  def skipped? fname
    @input_options.skipped? fname
  end

  def stdin?
    size == 1 && self[0] == '-'
  end

  def directory? idx
    fd = self[idx]
    fd && FileType.type(fd) == FileType::DIRECTORY
  end

  def each &blk
    @yielded_files = Array.new

    info "blk: #{blk}".on_red
    (0 ... size).each do |idx|
      fd = self[idx]
      info "fd: #{fd}".yellow
      type = FileType.type fd
      info "type: #{type}".yellow

      if stdin?
        blk.call [ :text, '-' ]
        next
      end

      handle_fd fd, &blk
    end
  end

  def handle_fd fd, &blk
    type = FileType.type fd

    case type
    when FileType::TEXT
      unless skipped? fd
        blk.call [ FileType::TEXT, fd ]
      end
    when FileType::DIRECTORY
      handle_directory fd, &blk
    when FileType::BINARY
      handle_binary fd, &blk
    when FileType::NONE
      write "no such file: #{fd}"
    when FileType::UNKNOWN
      write "unknown file type: #{fd}"
    when FileType::UNREADABLE
      log { "skipping unreadable: #{fd}" }
    end
  end

  def handle_directory fd, &blk
    case @input_options.directory
    when "read"
      write "#{fd}: is a directory"
    when "recurse"
      begin
        entries = Dir.entries(fd).reject { |x| x == "." || x == ".." }
        entries.sort.each do |e|
          entname = fd + "/" + e
          inode = File.exists?(entname) && File.stat(entname).ino
          next if inode && @yielded_files.include?(inode)
          @yielded_files << inode
          handle_fd entname, &blk
        end
      rescue Errno::EACCES => e
        write "directory not readable: #{fd}"
      end
    when "skip"
      nil
    end
  end

  def handle_binary fd, &blk
    return if skipped? fd

    case @input_options.binary_files
    when "binary"
      blk.call [ FileType::BINARY, fd ]
    when "text"
      blk.call [ FileType::TEXT, fd ]
    end
  end
end

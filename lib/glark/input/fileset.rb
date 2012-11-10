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

    if fnames.size == 0
      self << '-'
    else
      fnames.each do |fname|
        info "fname: #{fname}".yellow
        if @input_options.split_as_path
          info "fname: #{fname}".on_yellow
          fname.split(File::PATH_SEPARATOR).each do |path|
            pn = Pathname.new path
            info "pn: #{pn}"
            pn = Pathname.new path
            next if pn.file? && skipped?(pn)
            self << pn
          end
        else
          pn = Pathname.new fname
          info "pn: #{pn}"
          next if pn.file? && skipped?(pn)
          self << pn
        end
      end      
    end

    info "self: #{self.inspect}"

    # to keep from cycling through links:
    @yielded_files = nil
  end

  def skipped? fd
    @input_options.skipped? fd
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

    depth = 0

    info "blk: #{blk}".on_red
    (0 ... size).each do |idx|
      fd = self[idx]
      info "fd: #{fd}".yellow
      type = FileType.type fd.to_s
      info "type: #{type}".yellow

      if stdin?
        blk.call [ :text, '-' ]
        next
      end

      handle_fd fd, depth, &blk
    end
  end

  def handle_fd fd, depth, &blk
    info "fd: #{fd}".red
    type = FileType.type fd.to_s
    info "type: #{type}".red

    case type
    when FileType::TEXT
      unless skipped? fd
        blk.call [ FileType::TEXT, fd ]
      end
    when FileType::DIRECTORY
      handle_directory fd, depth, &blk
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

  def handle_directory fd, depth, &blk
    info "fd: #{fd}".cyan

    return if @input_options.directory == "skip"

    info "@input_options.directory: #{@input_options.directory}".green

    maxdepth = @input_options.directory == "list" ? 1 : nil

    info "maxdepth: #{maxdepth}".blue

    if maxdepth.nil? || depth < maxdepth
      begin
        fd.children.sort.each do |entry|
          next if @yielded_files.include?(entry)
          @yielded_files << entry
          handle_fd entry, depth + 1, &blk
        end
      rescue Errno::EACCES => e
        write "directory not readable: #{fd}"
      end
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

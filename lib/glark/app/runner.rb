#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'English'
require 'rubygems'
require 'riel'
require 'glark/app/options'
require 'glark/input/file'
require 'glark/output/binary_file'
require 'glark/output/file_names'
require 'glark/output/glark_count'
require 'glark/output/glark_lines'
require 'glark/output/grep_count'
require 'glark/output/grep_lines'
require 'glark/output/options'
require 'glark/output/unfiltered_lines'

$stdout.sync = true             # unbuffer
$stderr.sync = true             # unbuffer

module Glark; end

# The main processor.
class Glark::Runner
  include Loggable

  attr_reader :exit_status
  
  def initialize opts, func, files
    @opts = opts
    @func = func
    @searched_files = Array.new          # files searched, so we don't cycle through links
    
    @files = files

    @opts.output_options.set_files @files

    @invert_match = @opts.output_options.invert_match

    # 0 == matches, 1 == no matches, 2 == error
    @exit_status = @invert_match ? 0 : 1
  end

  def search_file file, output_type
    @func.process file, output_type

    if output_type.matched?
      @exit_status = @invert_match ? 1 : 0
    end
  end

  def skipped? fname
    @opts.input_options.skipped? fname
  end

  def create_file filecls, name, io
    file = filecls.new name, io, @opts.range
    output_opts = @opts.output_options

    output_type = nil
    
    if output_opts.count
      if output_opts.style == "grep" 
        output_type = GrepCount.new file, output_opts
      else
        output_type = GlarkCount.new file, output_opts
      end
    elsif output_opts.file_names_only
      output_type = FileNames.new file, output_opts
    elsif !output_opts.filter
      output_type = UnfilteredLines.new file, output_opts
    elsif output_opts.style == "grep"
      output_type = GrepLines.new file, output_opts
    else
      output_type = GlarkLines.new file, output_opts
    end

    [ file, output_type ]
  end

  def search_text fname
    return if skipped? fname

    io = fname == "-" ? $stdin : File.new(fname)

    file, output_type = create_file Glark::File, fname, io
    search_file file, output_type
  end

  def search_binary fname
    return if skipped? fname

    case @opts.input_options.binary_files
    when "without-match"
      nil
      
    when "binary"
      file = File.new fname
      file.binmode            # for MSDOS/WinWhatever
      file = Glark::File.new fname, file, nil
      output_opts = @opts.output_options
      output_type = BinaryFile.new file, output_opts
      search_file file, output_type
      
    when "text"
      search_text fname
    end
  end

  def search_directory fname
    case @opts.input_options.directory
    when "read"
      write "#{fname}: Is a directory"
    when "recurse"
      begin
        entries = Dir.entries(fname).reject { |x| x == "." || x == ".." }
        entries.sort.each do |e|
          entname = fname + "/" + e
          inode = File.exists?(entname) && File.stat(entname).ino
          next if inode && @searched_files.include?(inode)
          @searched_files << inode
          search entname 
        end
      rescue Errno::EACCES => e
        write "directory not readable: #{fname}"
      end
    when "skip"
      nil
    end
  end

  def search_unknown fname
    warn "unknown file type: #{fname}"
  end
  
  def search_none fname
    write "no such file: #{fname}"
  end

  def search_unreadable fname
    log { "skipping unreadable: #{fname}" }
  end

  def search name
    if @opts.input_options.exclude_matching
      expr = @opts.expr
      return if expr.respond_to?(:re) && expr.re.match(name)
    end
    
    if name == "-" 
      write "reading standard input..."
      search_text "-"
    else
      type = FileType.type name

      case type
      when FileType::BINARY
        search_binary name 
      when FileType::DIRECTORY
        search_directory name 
      when FileType::NONE
        search_none name 
      when FileType::TEXT
        search_text name 
      when FileType::UNKNOWN
        search_unknown name 
      when FileType::UNREADABLE
        search_unreadable name 
      else
        error "type unknown: file: #{name}; type: #{type}"
        exit(-2)
      end
    end
  end

  def end_processing
  end
end

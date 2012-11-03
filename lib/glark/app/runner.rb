#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'English'
require 'rubygems'
require 'riel'
require 'glark/app/options'
require 'glark/input/binary_file'
require 'glark/input/file'
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

    @invert_match = @opts.invert_match

    # 0 == matches, 1 == no matches, 2 == error
    @exit_status = @invert_match ? 0 : 1

    @skip_methods = Array.new

    if @opts.with_basename || @opts.without_basename
      @skip_methods << Proc.new { |fn| skip?(File.basename(fn), @opts.with_basename, @opts.without_basename) }
    end

    if @opts.with_fullname || @opts.without_fullname
      @skip_methods << Proc.new { |fn| skip?(fn, @opts.with_fullname, @opts.without_fullname) }
    end
    
    if @opts.size_limit
      @skip_methods << Proc.new { |fn| File.size(fn) > @opts.size_limit }
    end    
  end

  def search_file file, output_type
    @func.process file, output_type

    if output_type.matched?
      @exit_status = @invert_match ? 1 : 0
    end
  end

  def skip? name, opts_with, opts_without
    inc = opts_with    && !opts_with.match(name)
    exc = opts_without &&  opts_without.match(name)
    inc || exc
  end

  def skipped? fname
    @skip_methods.detect { |meth| meth.call fname }
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
    if skipped? fname
      log { "skipping file: #{fname}" }
    else
      log { "searching text #{fname} for #{@func}" }
      io = fname == "-" ? $stdin : File.new(fname)

      file, output_type = create_file Glark::File, fname, io
      search_file file, output_type
    end
  end

  def search_binary fname
    if skipped? fname
      log { "skipping file: #{fname}" }
    else
      log { "handling binary" }
      
      case @opts.binary_files
      when "without-match"
        log { "skipping binary file #{fname}" }
        
      when "binary"
        log { "searching binary file #{fname} for #{@func}" }
        file = File.new fname
        file.binmode            # for MSDOS/WinWhatever
        bf = BinaryFile.new fname, file
        search_file bf
        
      when "text"
        log { "processing binary file #{name} as text" }
        search_text fname
      end
    end
  end

  def search_directory fname
    log { "processing directory" }
    case @opts.directory
    when "read"
      write "#{fname}: Is a directory"
    when "recurse"
      log { "recursing into directory #{fname}" }
      begin
        entries = Dir.entries(fname).reject { |x| x == "." || x == ".." }
        entries.each do |e|
          entname = fname + "/" + e
          inode = File.exists?(entname) && File.stat(entname).ino
          if inode && @searched_files.include?(inode)
            Log.verbose && log("file already processed: #{entname}")
          else
            @searched_files << inode
            search entname 
          end
        end
      rescue Errno::EACCES => e
        write "directory not readable: #{fname}"
      end
    when "skip"
      log { "skipping directory #{fname}" }
    else
      log { "directory: #{@opts.directory}" }
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
    if @opts.exclude_matching
      expr = @opts.expr
      if expr.respond_to?(:re) && expr.re.match(name)
        log { "skipping file #{name} with matching name" }
        return
      else
        log { "not skipping file #{name}" }
      end
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

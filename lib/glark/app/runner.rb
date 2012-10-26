#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'English'
require 'rubygems'
require 'riel'
require 'glark/options'
require 'glark/input'
require 'glark/output'
require 'glark/expression'

$stdout.sync = true             # unbuffer
$stderr.sync = true             # unbuffer

module Glark; end

# The main processor.
class Glark::Runner
  include Loggable

  attr_reader :exit_status
  
  def initialize func, files
    @opts  = GlarkOptions.instance
    @func  = func
    @searched_files = Array.new          # files searched, so we don't cycle through links
    
    @files = files

    @show_file_names = (@opts.show_file_names ||
                        (@opts.show_file_names.nil? && 
                         (@opts.label ||
                          @files.size > 1 ||
                          (@files[0] != "-" && FileType.type(@files[0]) == FileType::DIRECTORY))))

    @out_class = case @opts.output
                 when "grep"
                   GrepOutputFormat
                 when "ansi", "xterm", nil
                   GlarkOutputFormat
                 when "match"
                   error "output to match list is not yet supported"
                   GlarkMatchList
                   # exit 2
                 end

    @count        = @opts.count
    @invert_match = @opts.invert_match

    @after  = @opts.after
    @before = @opts.before
    @output = @opts.output

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
      @skip_methods << Proc.new { |fn| File.size(fname) > @opts.size_limit }
    end    
  end

  def search_file input 
    output       = @out_class.new input, @show_file_names 
    input.output = output

    input.count        = 0    if @count
    input.invert_match = true if @invert_match
    
    @func.process input 

    if input.matched?
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

  def search_text fname
    if skipped? fname
      log { "skipping file: #{fname}" }
    else
      log { "searching text" }
      if false
        # readlines doesn't work with $/ == nil, so we'll use gets instead.
        # this has been fixed in the CVS version of Ruby (on 26 Dec 2003).
        text = []
        File.open(fname) do |f|
          while ((line = f.gets) && line.length > 0)
            text << line
          end
        end
        log { "got text #{text.length}" }
      end
      log { "searching #{fname} for #{@func}" }

      ifile_args = {
        :after  => @after,
        :before => @before,
        :output => @output
      }

      io = fname == "-" ? $stdin : File.new(fname)

      input = InputFile.new fname, io, ifile_args
      search_file input
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
        f = File.new fname
        f.binmode                # for MSDOS/WinWhatever
        bf = BinaryFile.new fname, f
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

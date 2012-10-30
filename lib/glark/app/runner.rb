#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'English'
require 'rubygems'
require 'riel'
require 'glark/app/options'
require 'glark/io/binary_file'
require 'glark/io/file'
require 'glark/results/file_name_format'
require 'glark/results/glark_format'
require 'glark/results/glark_count_format'
require 'glark/results/grep_count_format'
require 'glark/results/grep_format'
require 'glark/results/nonfilter_format'

$stdout.sync = true             # unbuffer
$stderr.sync = true             # unbuffer

module Glark; end

# The main processor.
class Glark::Runner
  include Loggable

  attr_reader :exit_status
  
  def initialize func, files
    @opts  = Glark::Options.instance
    @func  = func
    @searched_files = Array.new          # files searched, so we don't cycle through links
    
    @files = files

    @show_file_names = (@opts.show_file_names ||
                        (@opts.show_file_names.nil? && 
                         (@opts.label ||
                          @files.size > 1 ||
                          (@files[0] != "-" && FileType.type(@files[0]) == FileType::DIRECTORY))))

    @formatter_cls = case @opts.output
                     when "grep"
                       GrepOutputFormat
                     when "ansi", "xterm", nil
                       GlarkOutputFormat
                     when "match"
                       error "output to match list is not yet supported"
                       GlarkMatchList
                       # exit 2
                     end
    
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
      @skip_methods << Proc.new { |fn| File.size(fn) > @opts.size_limit }
    end    
  end

  def search_file file, formatter
    @func.process file, formatter

    if formatter.matched?
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
    file = filecls.new name, io

    format_opts = FormatOptions.new

    format_opts.after = @opts.after
    format_opts.before = @opts.before
    format_opts.file_highlight = @opts.file_highlight
    format_opts.filter = @opts.filter
    format_opts.highlight = @opts.highlight
    format_opts.invert_match = @opts.invert_match
    format_opts.label = @opts.label
    format_opts.line_number_highlight = @opts.line_number_highlight
    format_opts.out = @opts.out
    format_opts.show_file_names = @show_file_names
    info "@opts.show_line_numbers: #{@opts.show_line_numbers}".bold
    format_opts.show_line_numbers = @opts.show_line_numbers
    format_opts.write_null = @opts.write_null

    if @opts.count
      if @opts.output == "grep" 
        formatter = GrepCountFormat.new file, format_opts
      else
        formatter = GlarkCountFormat.new file, format_opts
      end
    elsif @opts.file_names_only
      formatter = FileNameFormat.new file, format_opts
    elsif !@opts.filter
      formatter = NonFilterFormat.new file, format_opts
    else
      formatter = @formatter_cls.new file, format_opts
    end

    [ file, formatter ]
  end

  def search_text fname
    if skipped? fname
      log { "skipping file: #{fname}" }
    else
      log { "searching text #{fname} for #{@func}" }
      io = fname == "-" ? $stdin : File.new(fname)

      file, formatter = create_file Glark::File, fname, io
      search_file file, formatter
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

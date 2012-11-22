#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel'
require 'glark/app/options'
require 'glark/input/file'
require 'glark/input/fileset'

$stdout.sync = true             # unbuffer
$stderr.sync = true             # unbuffer

module Glark; end

# The main processor.
class Glark::Runner
  include Loggable

  attr_reader :exit_status
  
  def initialize opts, files
    @opts = opts
    @expr = opts.expr
    @searched_files = Array.new          # files searched, so we don't cycle through links

    @invert_match = @opts.output_options.invert_match

    # 0 == matches, 1 == no matches, 2 == error
    @exit_status = @invert_match ? 0 : 1
    
    @opts.files.each do |type, file|
      search type, file
    end
  end

  def search_file file, output_type
    @expr.process file, output_type

    if output_type.matched?
      @exit_status = @invert_match ? 1 : 0
    end
  end

  def create_file filecls, name, io
    file = filecls.new name, io, @opts.range
    output_opts = @opts.output_options
    output_type = output_opts.create_output_type file

    [ file, output_type ]
  end

  def search_text fname
    io = fname == "-" ? $stdin : File.new(fname)

    file, output_type = create_file Glark::File, fname, io
    search_file file, output_type
  end

  def search_binary fname
    file = File.new fname
    file.binmode            # for MSDOS/WinWhatever
    file = Glark::File.new fname, file, nil
    output_opts = @opts.output_options
    output_type = BinaryFileSummary.new file, output_opts
    search_file file, output_type
  end

  def search_read fname
    info "fname: #{fname}".yellow

    extname = fname.extname
    info "extname: #{extname}".cyan
    case extname
    when '.gz'
      require 'zlib'
      Zlib::GzipReader.open(fname) do |gz|
        info "gz: #{gz}".red
        file, output_type = create_file Glark::File, fname, gz
        search_file file, output_type
      end
    when '.tar'
      @opts.output_options.show_file_names = true
      each_tar_entry(fname) do |entry|
        contents = StringIO.new entry.read
        file, output_type = create_file Glark::File, entry.full_name + " (in #{fname})", contents
        search_file file, output_type
      end
    else
      raise "extension '#{extname}' is not handled"
    end
  end

  def each_tar_entry fname, &blk
    # module Gem::Package is declared in 'rubygems/package', not in
    # .../tar_reader.
    require 'rubygems/package'
    require 'rubygems/package/tar_reader'

    entries = Array.new

    f = File.new fname
    tr = Gem::Package::TarReader.new f

    tr.each do |entry|
      if entry.file?
        blk.call entry
      end
    end
    entries
  end

  def search_list fname
    extname = fname.extname
    info "extname: #{extname}".yellow

    case extname
    when '.tar'
      contents = StringIO.new 
      each_tar_entry(fname) do |entry|
        contents << "#{entry.full_name}\n"
      end
    end
    contents.rewind
    
    file, output_type = create_file Glark::File, fname, contents
    search_file file, output_type
  end

  def search_archive fname
    extname = fname.extname
    info "extname: #{extname}".yellow

    case extname
    when '.tar'
      entries = get_tar_entries fname
      entries.each do |entry|
        contents = StringIO.new entry.read
        file, output_type = create_file Glark::File, entry.full_name + " (in #{fname})", contents
        search_file file, output_type
      end
    end
  end
  
  def search type, name
    if @opts.input_options.exclude_matching
      expr = @opts.expr
      return if expr.respond_to?(:re) && expr.re.match(name)
    end
    
    if name == "-" 
      write "reading standard input..."
      search_text "-"
    else
      case type
      when FileType::BINARY
        search_binary name 
      when FileType::TEXT
        search_text name 
      when :decompress, :read
        search_read name 
      when :list
        search_list name 
      else
        raise "type unknown: file: #{name}; type: #{type}"
      end
    end
  end
end

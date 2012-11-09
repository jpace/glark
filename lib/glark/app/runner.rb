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
      else
        raise "type unknown: file: #{name}; type: #{type}"
      end
    end
  end
end

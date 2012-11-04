#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/app/info/options'
require 'glark/app/rcfile'
require 'glark/match/options'
require 'glark/input/options'
require 'glark/input/range'
require 'glark/output/options'
require 'glark/output/context'
require 'glark/util/colors'
require 'glark/util/optutil'

module Glark
  PACKAGE = 'glark'
  VERSION = '1.9.1'
end

# -------------------------------------------------------
# Options
# -------------------------------------------------------

class Glark::Options
  include Loggable, Glark::OptionUtil

  attr_accessor :exclude_matching
  attr_accessor :local_config_files
  attr_accessor :split_as_path

  attr_reader :colors

  def expr
    @matchopts.expr
  end

  def out= io
    @outputopts.out = io
  end
  
  def initialize
    optdata = Array.new

    @colors = Glark::Colors.new    

    add_input_options optdata
    add_match_options optdata
    add_output_options optdata
    add_info_options optdata
    
    @optset = OptProc::OptionSet.new optdata
    
    @exclude_matching      = false      # exclude files whose names match the expression
    @explain               = false      # display a legible version of the expression
    @local_config_files    = false      # use local .glarkrc files

    @split_as_path         = true       # whether to split arguments that include the path separator
    
    @outputopts.style = "glark"
  end

  def range
    @inputopts.range
  end

  def add_input_options optdata
    @inputopts = InputOptions.new
    @inputopts.add_as_options optdata
    
    optdata << exclude_matching_option = {
      :tags => %w{ -M --exclude-matching },
      :set  => Proc.new { @exclude_matching = true }
    }

    optdata << no_split_as_path_option = {
      :tags => %w{ --no-split-as-path },
      :set  => Proc.new { @split_as_path = false }
    }

    optdata << split_as_path_option = {
      :tags => %w{ --split-as-path },
      :arg  => [ :boolean, :optional ],
      :set  => Proc.new { |val| @split_as_path = val }
    }
  end
  
  def add_match_options optdata
    @matchopts = MatchOptions.new @colors
    @matchopts.add_as_options optdata
  end

  def add_output_options optdata
    @outputopts = OutputOptions.new @colors
    @outputopts.add_as_options optdata
  end

  def add_info_options optdata
    @infoopts = Glark::InfoOptions.new @colors
    @infoopts.add_as_options optdata

    optdata << config_option = {
      :tags => %w{ --conf },
      :set  => Proc.new { write_configuration; exit }
    }

    optdata << dump_option = {
      :tags => %w{ --dump },
      :set  => Proc.new { dump_all_fields; exit 0 }
    }
  end
  
  def run args
    @args = args

    read_home_rcfiles

    if @local_config_files
      read_local_rcfiles
    end

    read_environment_variable

    # honor thy EMACS; go to grep mode
    if ENV["EMACS"]
      @outputopts.style = "grep"
    end

    read_options

    validate!
  end

  def read_home_rcfiles
    if hdir = Env.home_directory
      hdpn = Pathname.new hdir
      homerc = hdpn + ".glarkrc"
      read_rcfile homerc
    end
  end

  def read_local_rcfiles
    hdir = Env.home_directory
    dir = Pathname.new(".").expand_path
    while !dir.root? && dir != hdir
      rcfile = dir + ".glarkrc"
      if rcfile.exist?
        read_rcfile rcfile
        return
      else
        dir = dir.dirname
      end
    end
  end

  def set_record_separator sep
    log { "sep: #{sep}" }
    $/ = if sep && sep.to_i > 0
           begin
             sep.oct.chr
           rescue RangeError => e
             # out of range (e.g., 777) means nil:
             nil
           end
         else
           log { "setting to paragraph" }
           "\n\n"
         end
    
    log { "record separator set to #{$/.inspect}" }
  end

  def all_option_sets
    [ @colors, @matchopts, @outputopts, @infoopts, @inputopts ]
  end

  def read_rcfile rcfname
    rcfile = Glark::RCFile.new rcfname

    rcvalues = rcfile.names.collect { |name| [ name, rcfile.value(name) ] }

    all_option_sets.each do |opts|
      opts.update_fields rcvalues
    end
    
    rcfile.names.each do |name|
      value = rcfile.value name
      
      case name
      when "local-config-files"
        @local_config_files = to_boolean value
      when "split-as-path"
        @split_as_path = to_boolean value
      end
    end
  end

  def read_environment_variable
    options = Env.split "GLARKOPTS"
    while options.size > 0
      @optset.process_option options
    end
  end

  def read_expression
    if @args.size > 0
      known_end = false
      if @args[0] == "--"
        log { "end of options" }
        @args.shift
        known_end = true
      end
      
      if @args && @args.size > 0
        @matchopts.read_expression @args, !known_end
        return
      end
    end
    
    if @args.size > 0
      error "No expression provided."
    end
    
    $stderr.puts "Usage: glark [options] expression file..."
    $stderr.puts "Try `glark --help' for more information."
    exit 1
  end

  def read_options
    # solitary "-v" means "--version", not --invert-match
    @infoopts.show_version if @args.size == 1 && @args[0] == "-v"
    
    @matchopts.expr = nil
    
    nil while @args.size > 0 && @optset.process_option(@args)

    unless @matchopts.expr
      read_expression
    end
  end

  def write_configuration
    fields = {
      "local-config-files" => @local_config_files,
      "split-as-path" => @split_as_path,
    }
    all_option_sets.each do |opts|
      fields.merge! opts.config_fields
    end
    
    fields.keys.sort.each do |fname|
      puts "#{fname}: #{fields[fname]}"
    end
  end

  def dump_all_fields
    fields = {
      "exclude_matching" => @exclude_matching,
      "local_config_files" => @local_config_files,
    }
    all_option_sets.each do |opts|
      fields.merge! opts.dump_fields
    end

    len = fields.keys.collect { |f| f.length }.max
    
    fields.keys.sort.each do |field|
      printf "%*s : %s\n", len, field, fields[field]
    end
  end

  def match_options
    @matchopts
  end

  def output_options
    @outputopts
  end

  def info_options
    @infoopts
  end

  def input_options
    @inputopts
  end

  # check options for collisions/data validity
  def validate!
    @inputopts.range.validate!
  end
end

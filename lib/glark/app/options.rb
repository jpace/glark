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

  attr_accessor :local_config_files

  attr_reader :colors
  attr_reader :info_options
  attr_reader :input_options
  attr_reader :match_options
  attr_reader :output_options

  def expr
    @match_options.expr
  end

  def out= io
    @output_options.out = io
  end
  
  def initialize
    optdata = Array.new

    @colors = Glark::Colors.new    

    add_input_options optdata
    add_match_options optdata
    add_output_options optdata
    add_info_options optdata
    
    @optset = OptProc::OptionSet.new optdata
    
    @local_config_files = false      # use local .glarkrc files
    
    @output_options.style = "glark"
  end

  def range
    @input_options.range
  end

  def add_input_options optdata
    @input_options = InputOptions.new optdata
  end
  
  def add_match_options optdata
    @match_options = MatchOptions.new @colors, optdata
  end

  def add_output_options optdata
    @output_options = OutputOptions.new @colors, optdata
  end

  def add_info_options optdata
    @info_options = Glark::InfoOptions.new @colors, optdata
    
    optdata << config_option = {
      :tags => %w{ --config },
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
      @output_options.style = "grep"
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

  def all_option_sets
    [ @colors, @match_options, @output_options, @info_options, @input_options ]
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
        @args.shift
        known_end = true
      end
      
      if @args && @args.size > 0
        @match_options.read_expression @args, !known_end
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
    @info_options.show_version if @args.size == 1 && @args.first == "-v"
    
    @match_options.expr = nil
    
    nil while @args.size > 0 && @optset.process_option(@args)

    unless @match_options.expr
      read_expression
    end
  end

  def write_configuration
    fields = {
      "local-config-files" => @local_config_files,
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

  # check options for collisions/data validity
  def validate!
    @input_options.range.validate!
  end
end

#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/app/info/options'
require 'glark/app/rcfile'
require 'glark/app/spec'
require 'glark/input/options'
require 'glark/match/options'
require 'glark/output/options'
require 'glark/util/colors'
require 'glark/util/options'
require 'glark/util/optutil'

class Glark::AppOptions < Glark::AppSpec
  include Glark::OptionUtil
  
  attr_reader :colors
  attr_reader :fileset
  attr_reader :info_options
  attr_reader :output_options
  
  def initialize
    optdata = Array.new

    @colors = Glark::Colors.new    

    @input_options = Glark::InputOptions.new optdata
    @match_options = Glark::MatchOptions.new @colors, optdata
    @output_options = Glark::OutputOptions.new @colors, optdata

    @info_options = Glark::InfoOptions.new @colors, optdata

    add_opt_blk(optdata, %w{ --config }) { write_configuration; exit }
    add_opt_blk(optdata, %w{ --dump }) { dump_all_fields; exit 0 }

    super @input_options, @match_options, @output_options
    
    @optset = OptProc::OptionSet.new optdata
  end
  
  def run args
    @args = args

    read_home_rcfile

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

    @fileset = @input_options.create_fileset @args

    if @output_options.show_file_names.nil?
      @output_options.show_file_names = @output_options.label || !one_file?
    end
  end

  def one_file?
    return false if @fileset.size > 1
    first = @fileset.files.first
    first.to_s != '-' && first.file?
  end

  def read_home_rcfile
    if hdir = Dir.home
      hdpn = Pathname.new hdir
      homerc = hdpn + ".glarkrc"
      read_rcfile homerc
    end
  end

  def read_local_rcfiles
    hdir = Dir.home
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
    rcvalues = rcfile.names.collect { |name| [ name, rcfile.values(name) ] }

    all_option_sets.each do |opts|
      opts.update_fields rcvalues
    end

    update_fields rcvalues
  end

  def config_fields
    fields = {
      "local-config-files" => @local_config_files,
    }
  end

  def dump_fields
    config_fields
  end

  def update_fields fields
    fields.each do |name, values|
      case name
      when "local-config-files"
        @local_config_files = to_boolean values.last
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
      raise "No expression provided."
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
    fields = config_fields
    all_option_sets.each do |opts|
      fields.merge! opts.config_fields
    end
    
    fields.keys.sort.each do |fname|
      puts "#{fname}: #{fields[fname]}"
    end
  end

  def dump_all_fields
    fields = dump_fields
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

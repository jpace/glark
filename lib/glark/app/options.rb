#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/app/info/options'
require 'glark/app/rcfile'
require 'glark/match/options'
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

  attr_accessor :binary_files
  attr_accessor :directory
  attr_accessor :exclude_matching
  attr_accessor :extract_matches
  attr_accessor :local_config_files
  attr_accessor :size_limit
  attr_accessor :split_as_path
  attr_accessor :with_basename
  attr_accessor :with_fullname
  attr_accessor :without_basename
  attr_accessor :without_fullname

  attr_reader :colors
  attr_reader :range

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
    
    @binary_files          = "binary"   # 
    @directory             = "read"     # read, skip, or recurse, a la grep
    @exclude_matching      = false      # exclude files whose names match the expression
    @explain               = false      # display a legible version of the expression
    @extract_matches       = false      # whether to show _only_ the part that matched
    @local_config_files    = false      # use local .glarkrc files

    @split_as_path         = true       # whether to split arguments that include the path separator
    @with_basename         = nil        # match files with this basename
    @with_fullname         = nil        # match files with this fullname
    @without_basename      = nil        # match files without this basename
    @without_fullname      = nil        # match files without this fullname
    
    @size_limit = nil

    $/ = "\n"

    @outputopts.style = "glark"
  end

  def add_input_options optdata
    optdata << record_separator_option = {
      :res => [ Regexp.new '^ -0 (\d{1,3})? $ ', Regexp::EXTENDED ],
      :set => Proc.new { |md| rs = md ? md[1] : 0; set_record_separator rs }
    }

    @range = Glark::Range.new # range to start and stop searching; nil => the entire file
    @range.add_as_option optdata
    
    optdata << exclude_matching_option = {
      :tags => %w{ -M --exclude-matching },
      :set  => Proc.new { @exclude_matching = true }
    }

    optdata << exclude_matching_option = {
      :tags => %w{ -d },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @directory = val }
    }

    optdata << exclude_matching_option = {
      :tags => %w{ -r --recurse },
      :set  => Proc.new { @directory = "recurse" }
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

    optdata << dir_option = {
      :tags => %w{ --directories },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @directory = val }
    }

    optdata << basename_option = {
      :tags => %w{ --basename --name --with-basename --with-name },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @with_basename = Regexp.create pat }
    }

    optdata << without_basename_option = {
      :tags => %w{ --without-basename --without-name },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @without_basename = Regexp.create pat }
    }

    optdata << fullname_option = {
      :tags => %w{ --fullname --path --with-fullname --with-path },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @with_fullname = Regexp.create pat }
    }

    optdata << without_fullname_option = {
      :tags => %w{ --without-fullname --without-path },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @without_fullname = Regexp.create pat }
    }

    optdata << binary_files_option = {
      :tags    => %w{ --binary-files },
      :arg     => [ :required, :regexp, %r{ ^ [\'\"]? (text|without\-match|binary) [\'\"]? $ }x ],
      :set     => Proc.new { |md| @binary_files = md[1] },
      :rc   => %w{ binary-files },
    }

    optdata << size_limit_option = {
      :tags => %w{ --size-limit },
      :arg  => [ :integer ],
      :set  => Proc.new { |val| @size_limit = val }
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

  def read_rcfile rcfname
    rcfile = Glark::RCFile.new rcfname

    rcvalues = rcfile.names.collect { |name| [ name, rcfile.value(name) ] }

    [ @colors, @matchopts, @outputopts, @infoopts ].each do |opts|
      opts.update_fields rcvalues
    end
    
    rcfile.names.each do |name|
      value = rcfile.value name
      
      case name
      when "local-config-files"
        @local_config_files = to_boolean value
      when "split-as-path"
        @split_as_path = to_boolean value
      when "size-limit"
        @size_limit = value.to_i
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
      "binary-files" => @binary_files,
      "local-config-files" => @local_config_files,
      "size-limit" => @size_limit,
      "split-as-path" => @split_as_path,
    }
    [ @colors, @matchopts, @outputopts, @infoopts ].each do |opts|
      fields.merge! opts.config_fields
    end
    
    fields.keys.sort.each do |fname|
      puts "#{fname}: #{fields[fname]}"
    end
  end

  def dump_all_fields
    fields = {
      "binary_files" => @binary_files,
      "directory" => @directory,
      "exclude_matching" => @exclude_matching,
      "extract_matches" => @extract_matches,
      "local_config_files" => @local_config_files,
      "with-basename" => @with_basename,
      "with-fullname" => @with_fullname,
      "without-basename" => @without_basename,
      "without-fullname" => @without_fullname,
    }
    [ @colors, @matchopts, @outputopts, @infoopts ].each do |opts|
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

  # check options for collisions/data validity
  def validate!
    @range.validate!
  end
end

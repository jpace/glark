#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for input.

require 'rubygems'
require 'riel/log'
require 'glark/input/range'
require 'glark/util/optutil'

class InputOptions
  include Loggable, Glark::OptionUtil  

  attr_reader :binary_files     # how to process binary (non-text) files
  attr_reader :exclude_matching # exclude files whose names match the expression
  attr_reader :range            # range to start and stop searching; nil => the entire file
  attr_reader :size_limit       # maximum size of files to be searched
  attr_reader :directory        # read, skip, or recurse, a la grep
  attr_reader :with_basename    # match files with this basename
  attr_reader :with_fullname    # match files with this fullname
  attr_reader :without_basename # match files without this basename
  attr_reader :without_fullname # match files without this fullname

  def initialize
    @binary_files = "binary"
    @directory = "read"
    @exclude_matching = false      # exclude files whose names match the expression
    @range = Glark::Range.new 
    @size_limit = nil
    @with_basename = nil
    @with_fullname = nil
    @without_basename = nil
    @without_fullname = nil
    @skip_methods = nil

    $/ = "\n"
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

  def config_fields
    fields = {
      "binary-files" => @binary_files,
      "size-limit" => @size_limit,
    }
  end

  def dump_fields
    fields = {
      "binary_files" => @binary_files,
      "directory" => @directory,
      "exclude_matching" => @exclude_matching,
      "size-limit" => @size_limit,
      "with-basename" => @with_basename,
      "with-fullname" => @with_fullname,
      "without-basename" => @without_basename,
      "without-fullname" => @without_fullname,
    }
  end

  def update_fields fields
    fields.each do |name, value|
      case name
      when "size-limit"
        @size_limit = value.to_i
      end
    end
  end

  def skip? name, opts_with, opts_without
    inc = opts_with    && !opts_with.match(name)
    exc = opts_without &&  opts_without.match(name)
    inc || exc
  end

  def skipped? fname
    unless @skip_methods
      @skip_methods = Array.new

      if @with_basename || @without_basename
        @skip_methods << Proc.new { |fn| skip?(File.basename(fn), @with_basename, @without_basename) }
      end
      
      if @with_fullname || @without_fullname
        @skip_methods << Proc.new { |fn| skip?(fn, @with_fullname, @without_fullname) }
      end
      
      if @size_limit
        @skip_methods << Proc.new { |fn| File.size(fn) > @size_limit }
      end
    end

    @skip_methods.detect { |meth| meth.call fname }
  end

  def add_as_options optdata    
    optdata << record_separator_option = {
      :res => [ Regexp.new '^ -0 (\d{1,3})? $ ', Regexp::EXTENDED ],
      :set => Proc.new { |md| rs = md ? md[1] : 0; set_record_separator rs }
    }

    @range.add_as_option optdata

    optdata << directory_option = {
      :tags => %w{ -d },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @directory = val }
    }

    optdata << recurse_option = {
      :tags => %w{ -r --recurse },
      :set  => Proc.new { @directory = "recurse" }
    }

    optdata << dir_option = {
      :tags => %w{ --directories },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @directory = val }
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

    optdata << exclude_matching_option = {
      :tags => %w{ -M --exclude-matching },
      :set  => Proc.new { @exclude_matching = true }
    }
  end
end

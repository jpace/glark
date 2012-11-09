#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for input.

require 'rubygems'
require 'riel/log'
require 'glark/input/range'
require 'glark/input/filter'
require 'glark/input/filterset'
require 'glark/util/options'

class InputOptions < Glark::Options
  attr_reader :binary_files     # how to process binary (non-text) files
  attr_reader :directory        # read, skip, or recurse, a la grep
  attr_reader :exclude_matching # exclude files whose names match the expression
  attr_reader :range            # range to start and stop searching; nil => the entire file
  attr_reader :size_limit       # maximum size of files to be searched
  attr_reader :split_as_path    # use file arguments as path elements
  attr_reader :match_name       # match files with this basename
  attr_reader :match_path       # match files with this fullname
  attr_reader :nomatch_name     # match files without this basename
  attr_reader :nomatch_path     # match files without this fullname

  def initialize optdata
    @binary_files = "binary"
    @directory = "read"
    @exclude_matching = false      # exclude files whose names match the expression
    @filterset = nil
    @range = Glark::Range.new 
    @size_limit = nil
    @skip_methods = nil
    @split_as_path = true
    @match_name = nil
    @match_path = nil
    @nomatch_name = nil
    @nomatch_path = nil

    $/ = "\n"

    add_as_options optdata
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
      "split-as-path" => @split_as_path,
    }
  end

  def dump_fields
    fields = {
      "binary_files" => @binary_files,
      "directory" => @directory,
      "exclude_matching" => @exclude_matching,
      "size-limit" => @size_limit,
      "split-as-path" => @split_as_path,
      "with-basename" => @match_name,
      "with-fullname" => @match_path,
      "without-basename" => @nomatch_name,
      "without-fullname" => @nomatch_path,
    }
  end

  def update_fields fields
    fields.each do |name, value|
      case name
      when "size-limit"
        @size_limit = value.to_i
      when "split-as-path"
        @split_as_path = to_boolean value
      end
    end
  end

  def skipped? fname
    unless @filterset
      @filterset = Glark::FilterSet.new
      
      if @match_name
        @filterset.add_positive_filter BaseNameFilter.new(@match_name)
      end

      if @match_path
        @filterset.add_positive_filter FullNameFilter.new(@match_path)
      end

      if @nomatch_name
        @filterset.add_negative_filter BaseNameFilter.new(@nomatch_name)
      end

      if @nomatch_path
        @filterset.add_negative_filter FullNameFilter.new(@nomatch_path)
      end

      if @size_limit
        @filterset.add_negative_filter SizeLimitFilter.new(@size_limit)
      end
    end

    @filterset.skipped? fname
  end
  
  def add_as_options optdata    
    optdata << record_separator_option = {
      :res => [ Regexp.new '^ -0 (\d{1,3})? $ ', Regexp::EXTENDED ],
      :set => Proc.new { |md| rs = md ? md[1] : 0; set_record_separator rs }
    }

    @range.add_as_option optdata

    optdata << recurse_option = {
      :tags => %w{ -r --recurse },
      :set  => set(:directory, "recurse")
    }

    add_opt_str optdata, :directory, %w{ -d --directories }
    
    optdata << binary_files_option = {
      :tags    => %w{ --binary-files },
      :arg     => [ :required, :regexp, %r{ ^ [\'\"]? (text|without\-match|binary) [\'\"]? $ }x ],
      :set     => Proc.new { |md| @binary_files = md[1] },
      :rc   => %w{ binary-files },
    }

    add_opt_int optdata, :size_limit, %w{ --size-limit }

    optdata << basename_option = {
      :tags => %w{ --basename --name --with-basename --with-name --match-name },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @match_name = Regexp.create pat }
    }

    optdata << nomatch_name_option = {
      :tags => %w{ --without-basename --without-name --not-name },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @nomatch_name = Regexp.create pat }
    }

    optdata << fullname_option = {
      :tags => %w{ --fullname --path --with-fullname --with-path --match-path },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @match_path = Regexp.create pat }
    }

    optdata << nomatch_path_option = {
      :tags => %w{ --without-fullname --without-path --not-path },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @nomatch_path = Regexp.create pat }
    }

    add_opt_true optdata, :exclude_matching, %w{ -M --exclude-matching }

    add_opt_false optdata, :split_as_path, %w{ --no-split-as-path }
    add_opt_true optdata, :split_as_path, %w{ --split-as-path }
  end
end

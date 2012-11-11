#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for input.

require 'rubygems'
require 'riel/log'
require 'glark/input/range'
require 'glark/input/filter'
require 'glark/input/file_filterset'
require 'glark/util/options'

class InputOptions < Glark::Options
  attr_reader :binary_files     # how to process binary (non-text) files
  attr_reader :directory        # read, skip, or recurse, a la grep
  attr_reader :exclude_matching # exclude files whose names match the expression
  attr_reader :range            # range to start and stop searching; nil => the entire file
  attr_reader :split_as_path    # use file arguments as path elements

  def initialize optdata
    @binary_files = "binary"
    @directory = "list"
    @directory_filterset = nil
    @exclude_matching = false      # exclude files whose names match the expression

    @file_filterset = nil

    @range = Glark::Range.new 
    @skip_methods = nil
    @split_as_path = true

    @match_dirname = nil
    @match_dirpath = nil
    @nomatch_dirname = '.svn'
    @nomatch_dirpath = nil

    @file_filterset = Glark::FileFilterSet.new

    $/ = "\n"

    add_as_options optdata
  end

  def match_names
    @file_filterset.match_names
  end

  def match_paths
    @file_filterset.match_paths
  end
  
  def nomatch_names
    @file_filterset.nomatch_names
  end

  def nomatch_paths
    @file_filterset.nomatch_paths
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
      "split-as-path" => @split_as_path,
    }.merge @file_filterset.config_fields
  end

  def dump_fields
    fields = {
      "binary_files" => @binary_files,
      "directory" => @directory,
      "exclude_matching" => @exclude_matching,
      "split-as-path" => @split_as_path,
      # "with-basename" => @match_name,
      # "with-fullname" => @match_path,
      # "without-basename" => @nomatch_name,
      # "without-fullname" => @nomatch_path,
    }.merge @file_filterset.dump_fields
  end

  def update_fields fields
    @file_filterset.update_fields fields

    fields.each do |name, value|
      case name
      when "split-as-path"
        @split_as_path = to_boolean value
      end
    end
  end

  def file_filters
    @file_filterset
  end

  def directory_filters
    unless @directory_filterset
      @directory_filterset = Glark::FilterSet.new

      pos_filters = Array.new
      pos_filters << [ BaseNameFilter, @match_dirname ]
      pos_filters << [ FullNameFilter, @match_dirpath ]

      pos_filters.each do |cls, var|
        add_filters :directory, :positive, cls, var
      end

      neg_filters = Array.new
      neg_filters << [ BaseNameFilter, @nomatch_dirname ]
      neg_filters << [ FullNameFilter, @nomatch_dirpath ]
      
      neg_filters.each do |cls, var|
        add_filters :directory, :negative, cls, var
      end
    end
    @directory_filterset
  end

  def add_filter type, posneg, cls, field
    meth = 'add_' + posneg.to_s + '_filter'
    var = instance_variable_get '@' + type.to_s + '_filterset'
    var.send meth.to_sym, cls.new(field)
  end

  def add_filters type, posneg, cls, field
    return unless field

    if field.kind_of? Array
      field.each do |fld|
        add_filter type, posneg, cls, fld
      end
    else
      add_filter type, posneg, cls, field
    end
  end

  def add_opt_regexp_ary optdata, tags, ary
    optdata << {
      :tags => tags,
      :arg  => [ :string ],
      :set  => Proc.new { |pat| ary << Regexp.create(pat) }
    }
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

    @file_filterset.add_as_options optdata

    add_opt_true optdata, :exclude_matching, %w{ -M --exclude-matching }

    add_opt_false optdata, :split_as_path, %w{ --no-split-as-path }
    add_opt_true optdata, :split_as_path, %w{ --split-as-path }
  end
end

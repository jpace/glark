#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for input.

require 'rubygems'
require 'glark/input/range'
require 'glark/input/binary_files_option'
require 'glark/input/filter/dir_criteria'
require 'glark/input/filter/file_criteria'
require 'glark/util/options'

class InputOptions < Glark::Options
  attr_reader :directory        # read, skip, or recurse, a la grep
  attr_reader :exclude_matching # exclude files whose names match the expression
  attr_reader :range            # range to start and stop searching; nil => the entire file
  attr_reader :split_as_path    # use file arguments as path elements

  attr_reader :file_criteria
  attr_reader :dir_criteria

  def initialize optdata
    @binary_files_option = BinaryFilesOption.new
    @directory = "list"
    @exclude_matching = false      # exclude files whose names match the expression

    @range = Glark::Range.new
    @split_as_path = true
    
    @file_criteria = Glark::FileCriteria.new
    @dir_criteria = Glark::DirCriteria.new

    $/ = "\n"

    add_as_options optdata
  end

  def binary_files
    @binary_files_option.process_as
  end

  def set_record_separator sep
    $/ = if sep && sep.to_i > 0
           begin
             sep.oct.chr
           rescue RangeError => e
             # out of range (e.g., 777) means nil:
             nil
           end
         else
           "\n\n"
         end
  end

  def config_fields
    fields = {
      "binary-files" => binary_files,
      "split-as-path" => @split_as_path,
    }
    fields.merge! @dir_criteria.config_fields
    fields.merge! @file_criteria.config_fields
  end

  def dump_fields
    fields = {
      "binary_files" => binary_files,
      "directory" => @directory,
      "exclude_matching" => @exclude_matching,
      "split-as-path" => @split_as_path,
    }
    fields.merge! @dir_criteria.dump_fields
    fields.merge! @file_criteria.dump_fields
    fields
  end

  def update_fields fields
    @dir_criteria.update_fields fields
    @file_criteria.update_fields fields

    fields.each do |name, value|
      case name
      when "split-as-path"
        @split_as_path = to_boolean value
      end
    end
  end
  
  def add_as_options optdata    
    optdata << record_separator_option = {
      :res => [ Regexp.new('^ -0 (\d{1,3})? $ ', Regexp::EXTENDED) ],
      :set => Proc.new { |md| rs = md ? md[1] : 0; set_record_separator rs }
    }

    @range.add_as_option optdata

    optdata << recurse_option = {
      :tags => %w{ -r --recurse },
      :set  => set(:directory, "recurse")
    }

    add_opt_str optdata, :directory, %w{ -d --directories }
    
    @binary_files_option.add_as_option optdata

    @file_criteria.add_as_options optdata
    @dir_criteria.add_as_options optdata

    add_opt_true optdata, :exclude_matching, %w{ -M --exclude-matching }

    add_opt_false optdata, :split_as_path, %w{ --no-split-as-path }
    add_opt_true optdata, :split_as_path, %w{ --split-as-path }
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'glark/input/range'
require 'glark/input/filter/dir_criteria'
require 'glark/input/filter/file_criteria'

class Glark::InputSpec  
  VALID_BINARY_FILE_TYPES = [ 'text', 'without-match', 'skip', 'binary', 'list', 'decompress', 'read' ]

  attr_reader :directory        # read, skip, or recurse, a la grep
  attr_reader :exclude_matching # exclude files whose names match the expression
  attr_reader :range            # range to start and stop searching; nil => the entire file
  attr_reader :split_as_path    # use file arguments as path elements

  attr_reader :file_criteria
  attr_reader :dir_criteria

  def initialize
    @binary_files = 'skip'
    @directory = "list"
    @exclude_matching = false      # exclude files whose names match the expression

    @range = Glark::Range.new
    @split_as_path = true
    
    @file_criteria = Glark::FileCriteria.new
    @dir_criteria = Glark::DirCriteria.new

    $/ = "\n"
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
end

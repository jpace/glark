#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/range'
require 'glark/input/filter/dir_criteria_opts'
require 'glark/input/filter/file_criteria_opts'

module Glark
  class InputSpec  
    VALID_BINARY_FILE_TYPES = [ 'text', 'without-match', 'skip', 'binary', 'list', 'decompress', 'read' ]

    attr_accessor :binary_files     # how to handle binary files
    attr_accessor :directory        # read, skip, or recurse, a la grep
    attr_accessor :exclude_matching # exclude files whose names match the expression
    attr_accessor :range            # range to start and stop searching; nil => the entire file
    attr_accessor :split_as_path    # use file arguments as path elements

    attr_accessor :dir_criteria
    attr_accessor :file_criteria
    attr_accessor :max_depth    

    def initialize
      @binary_files = 'skip'
      @directory = 'list'
      @exclude_matching = false

      @range = Range.new
      @split_as_path = true
      
      @file_criteria = FileCriteriaOpts.new
      @dir_criteria = DirCriteriaOpts.new nil

      @max_depth = 0            # list directories

      $/ = "\n"
    end
  end
end

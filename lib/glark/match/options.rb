#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for matching.

require 'rubygems'
require 'riel/log'

class MatchOptions
  include Loggable
  
  attr_accessor :expr
  attr_accessor :extended
  attr_accessor :extract_matches
  attr_accessor :highlight
  attr_accessor :ignorecase
  attr_accessor :text_highlights
  attr_accessor :whole_lines
  attr_accessor :whole_words

  def initialize 
    @expr = nil
    @extended = nil
    @extract_matches = nil
    @highlight = nil
    @ignorecase = nil
    @text_highlights = nil
    @whole_lines = nil
    @whole_words = nil
  end

  def add_as_options optdata
    optdata << whole_word_option = {
      :tags => %w{ -w --word },
      :set  => Proc.new { @whole_words = true }
    }
    
    optdata << ignore_case_option = {
      :tags => %w{ -i --ignore-case },
      :set  => Proc.new { @ignorecase = true }
    }

    optdata << whole_line_option = {
      :tags => %w{ -x --line-regexp },
      :set  => Proc.new { @whole_lines = true }
    }

    optdata << extended_option = {
      :tags => %w{ --extended },
      :set  => Proc.new { @extended = true }
    }
  end
end

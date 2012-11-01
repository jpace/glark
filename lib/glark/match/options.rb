#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for matching.

require 'rubygems'
require 'riel/log'
require 'glark/match/factory'

class MatchOptions
  include Loggable
  
  attr_accessor :expr           # the expression to be evaluated
  attr_accessor :extended       # whether to use extended regular expressions
  attr_accessor :extract_matches
  attr_accessor :highlight
  attr_accessor :ignorecase     # match case
  attr_accessor :text_highlights
  attr_accessor :whole_lines    # true means patterns must match the entire line
  attr_accessor :whole_words    # true means all patterns are '\b'ed front and back

  def initialize 
    @expr = nil
    @extended = false
    @extract_matches = false
    @highlight = nil
    @ignorecase = false
    @text_highlights = nil
    @whole_lines = false
    @whole_words = false
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

    optdata << expr_file_option = {
      :tags => %w{ -f --file },
      :arg  => [ :string ],
      :set  => Proc.new { |fname| @expr = ExpressionFactory.new(self).read_file fname }
    }

    optdata << orand_expr_option = {
      :tags => %w{ -o -a },
      :set  => Proc.new do |md, opt, args|
        args.unshift opt
        @expr = ExpressionFactory.new(self).make_expression args
      end
    }
  end
end

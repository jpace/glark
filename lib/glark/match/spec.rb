#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for matching.

require 'rubygems'
require 'riel/log'
require 'glark/match/factory'
require 'glark/util/colors'

class Glark::MatchSpec
  attr_accessor :expr           # the expression to be evaluated
  attr_accessor :extended       # whether to use extended regular expressions
  attr_accessor :extract_matches
  attr_accessor :ignorecase     # match case
  attr_accessor :whole_lines    # true means patterns must match the entire line
  attr_accessor :whole_words    # true means all patterns are '\b'ed front and back

  def initialize colors
    @colors = colors
    @expr = nil
    @extended = false
    @extract_matches = false
    @ignorecase = false
    @whole_lines = false
    @whole_words = false
  end
  
  def create_expression_factory
    exprargs = Hash.new
    exprargs[:extended] = @extended
    exprargs[:extract_matches] = @extract_matches
    exprargs[:ignorecase] = @ignorecase
    exprargs[:text_highlights] = text_highlights
    exprargs[:whole_lines] = @whole_lines
    exprargs[:whole_words] = @whole_words
    
    ExpressionFactory.new self
  end
  
  def read_expression args, warn_option = false
    @expr = create_expression_factory.make_expression args, warn_option
  end

  def text_highlights
    @colors.text_highlights
  end

  def set_text_highlights text_colors
    @colors.text_highlights = text_colors
  end

  def set_text_highlight index, text_color
    @colors.text_highlights[index] = text_color
  end
end

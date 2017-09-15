#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# RegexpExpression factory.

require 'rubygems'
require 'logue/loggable'
require 'riel/regexp'
require 'glark/match/re'

class RegexpExpressionFactory
  include Logue::Loggable

  attr_reader :count

  def initialize exprspec
    @count = 0
    @extended = exprspec[:extended]
    @extract_matches = exprspec[:extract_matches]
    @ignorecase = exprspec[:ignorecase]
    @text_colors = exprspec[:text_colors]
    @wholelines = exprspec[:whole_lines]
    @wholewords = exprspec[:whole_words]
  end

  def create_expression pattern, negated = false
    # this check is because they may have omitted the pattern, e.g.:
    #   % glark *.cpp
    if File.exist? pattern
      warn "pattern '#{pattern}' exists as a file.\n    Pattern may have been omitted."
    end

    regex = Regexp.create(pattern.dup, 
                          :negated    => negated, 
                          :ignorecase => @ignorecase,
                          :wholewords => @wholewords,
                          :wholelines => @wholelines,
                          :extended   => @extended)
    
    re = RegexpExpression.new regex, @count, @text_colors, @extract_matches
    @count += 1
    re
  end
end

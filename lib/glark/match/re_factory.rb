#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# RegexpExpression factory.

require 'rubygems'
require 'riel/regexp'
require 'glark/match/re'

class RegexpExpressionFactory
  include Loggable

  attr_reader :count

  def initialize expropts
    @count           = 0
    @ignorecase      = expropts.ignorecase
    @wholewords      = expropts.whole_words
    @wholelines      = expropts.whole_lines
    @extended        = expropts.extended
    @text_highlights = expropts.text_highlights
    @extract_matches = expropts.extract_matches
  end

  def create_expression pattern, negated = false
    # this check is because they may have omitted the pattern, e.g.:
    #   % glark *.cpp
    if File.exists? pattern
      warn "pattern '#{pattern}' exists as a file.\n    Pattern may have been omitted."
    end

    regex = Regexp.create(pattern.dup, 
                          :negated    => negated, 
                          :ignorecase => @ignorecase,
                          :wholewords => @wholewords,
                          :wholelines => @wholelines,
                          :extended   => @extended)

    re = RegexpExpression.new regex, @count, @text_highlights, @extract_matches
    @count += 1
    re
  end
end

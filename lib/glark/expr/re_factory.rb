#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# RegexpExpression factory.

require 'rubygems'
require 'riel/regexp'
require 'glark/expr/re'

class RegexpExpressionFactory
  include Loggable

  attr_reader :expr
  attr_reader :count

  def initialize expropts
    @count           = 0
    @ignorecase      = expropts.ignorecase
    @wholewords      = expropts.whole_words
    @wholelines      = expropts.whole_lines
    @extended        = expropts.extended
    @highlight       = expropts.highlight
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
    
    regex_args = {
      :highlight       => @highlight,
      :text_highlights => @text_highlights,
      :extract_matches => @extract_matches
    }    

    re = RegexpExpression.new regex, @count, regex_args
    @count += 1
    re
  end
end

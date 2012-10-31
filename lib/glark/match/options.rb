#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for matching.

class MatchOptions
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
end

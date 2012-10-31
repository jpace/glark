#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for matching.

class MatchOptions
  attr_accessor :extended
  attr_accessor :extract_matches
  attr_accessor :highlight
  attr_accessor :ignorecase
  attr_accessor :text_highlights
  attr_accessor :whole_lines
  attr_accessor :whole_words

  def initialize 
    @ignorecase = nil
    @whole_words = nil
    @whole_lines = nil
    @extended = nil
    @highlight = nil
    @text_highlights = nil
    @extract_matches = nil
  end
end

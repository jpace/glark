#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/match/expression'
require 'glark/util/highlight'

# Applies a regular expression against a File.
class RegexpExpression < Expression
  include Highlight
  
  attr_reader :re

  def initialize re, hlidx, text_highlights = nil, extract_matches = false
    @re = re

    if @text_highlights = text_highlights
      @hlidx = if @text_highlights.length > 0
                 hlidx % @text_highlights.length
               else
                 0
               end 
    end    
    @extract_matches = extract_matches
    
    super()
  end

  def == other
    @re == other.re
  end

  def inspect
    @re.inspect
  end

  def match? line
    @re.match line
  end

  def evaluate line, lnum, file, formatter
    md = match? line
    return false unless md

    if @extract_matches
      if md.kind_of? MatchData
        line.replace md[-1] + "\n"
      else
        warn "--not is incompatible with -v"
      end
    end
    
    @match_line_number = lnum

    if @text_highlights && @text_highlights.size > 0
      highlight_match lnum, file, formatter
    end
    
    add_match lnum
    true
  end
  
  def explain level = 0
    " " * level + to_s + "\n"
  end

  def highlight_match lnum, file, formatter
    lnums = file.get_region lnum
    return unless lnums

    lnums.each do |ln|
      str = formatter.formatted[ln] || file.get_line(ln)
      formatter.formatted[ln] = str.gsub(@re) do |m|
        lastcapts = Regexp.last_match.captures
        # the index of the first non-nil capture:
        miidx = (0 ... lastcapts.length).find { |mi| lastcapts[mi] } || @hlidx
        adorn(@text_highlights[miidx], m)
      end
    end
  end
end

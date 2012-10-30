#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/expr/expression'

# Applies a regular expression against a File.
class RegexpExpression < Expression
  attr_reader :re

  def initialize re, hlidx, args = Hash.new
    @re = re
    if @highlight = args[:highlight]
      @text_highlights = args[:text_highlights]
      @hlidx           = if @text_highlights.length > 0 && args[:highlight] == "multi"
                           hlidx % @text_highlights.length
                         else
                           0
                         end 
    end
    
    @extract_matches = args[:extract_matches]
    
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
    if Log.verbose
      log { "evaluating <<<#{line[0 .. -2]}>>>" }
    end
    
    md = match? line
    return false unless md

    log { "matched" }
    if @extract_matches
      if md.kind_of? MatchData
        line.replace md[-1] + "\n"
      else
        warn "--not does not work with -v"
      end
    end
    
    @match_line_number = lnum

    if @highlight
      highlight_match lnum, file, formatter
    end
    
    add_match lnum
    true
  end
  
  def explain level = 0
    " " * level + to_s + "\n"
  end

  def highlight_match lnum, file, formatter
    log { "lnum: #{lnum}; file: #{file}" }
    
    lnums = file.get_region lnum
    log { "lnums(#{lnum}): #{lnums}" }
    return unless lnums

    lnums.each do |ln|
      str = formatter.formatted[ln] || file.get_line(ln)
      formatter.formatted[ln] = str.gsub(@re) do |m|
        lastcapts = Regexp.last_match.captures
        # find the index of the first non-nil capture:
        miidx = (0 ... lastcapts.length).find { |mi| lastcapts[mi] } || @hlidx
        
        @text_highlights[miidx].highlight m
      end
    end
  end
end

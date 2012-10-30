#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Extended regular-expression-based expressions.

require 'rubygems'
require 'riel'
require 'glark/app/options'

# An expression, which can be applied (processed) against a Glark::File.
class Expression
  include Loggable
  
  attr_accessor :matches

  def initialize
    @match_line_number = nil
    @matches = Array.new
    
    opts = Glark::Options.instance

    @invert_match = opts.invert_match
    @range = opts.range
  end

  def add_match lnum
    @matches.push lnum
  end

  def start_position
    @match_line_number
  end

  def end_position
    start_position
  end

  def reset_file file
    @match_line_number = nil
    @matches = Array.new
  end

  def process file, formatter
    got_match = false
    reset_file file.fname
    
    rgstart  = @range && @range.to_line(@range.from, file.linecount)
    info "rgstart: #{rgstart}".yellow
    rgend    = @range && @range.to_line(@range.to,   file.linecount)
    info "rgend: #{rgend}".yellow

    info "formatter: #{formatter}".black.on_green
    
    lastmatch = 0
    lnum = 0
    file.each_line do |line|
      info "line: #{line.chomp}".cyan
      info "lnum: #{lnum}".cyan
      if ((!rgstart || lnum >= rgstart) && 
          (!rgend   || lnum < rgend)   &&
          evaluate(line, lnum, file, formatter))
        
        formatter.mark_as_match start_position, end_position
        
        if formatter.display_matches?
          formatter.write_matches !@invert_match, lastmatch, lnum
          lastmatch = lnum + 1
        end
        
        if formatter.at_match_limit?
          info "formatter.at_match_limit?: #{formatter.at_match_limit?}".bold.yellow.on_green
          # we've found the match limit
          break
        end
      end
      lnum += 1
    end

    formatter.process_end lnum
  end

  def to_s
    inspect
  end
end

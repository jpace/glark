#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Extended regular-expression-based expressions.

# An expression, which can be applied (processed) against a Glark::File.
class Expression
  attr_accessor :matches

  def initialize
    @match_line_number = nil
    @matches = Array.new
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
    reset_file file.fname

    rgstart = file.get_range_start
    rgend = file.get_range_end
    
    lastmatch = 0
    lnum = 0
    file.each_line do |line|
      if ((!rgstart || lnum >= rgstart) && 
          (!rgend   || lnum < rgend)   &&
          evaluate(line, lnum, file, formatter))

        break if formatter.process_match start_position, end_position, lastmatch, lnum
        lastmatch = lnum + 1
      end
      lnum += 1
    end

    formatter.process_end lnum
  end

  def to_s
    inspect
  end
end

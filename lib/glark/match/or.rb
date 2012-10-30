#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/match/compound'

# A collection of expressions, evaluated as 'or'.
class OrExpression < CompoundExpression

  def evaluate line, lnum, file, formatter
    matched_ops = @ops.select do |op|
      op.evaluate line, lnum, file, formatter
    end

    if is_match? matched_ops
      lastmatch          = matched_ops[-1]
      @last_start        = lastmatch.start_position
      @last_end          = lastmatch.end_position
      @match_line_number = lnum
      
      add_match lnum
      true
    else
      false
    end
  end

  def inspect
    "(" + @ops.collect { |op| op.to_s }.join(" " + operator + " ") + ")"
  end

  def end_position
    @last_end
  end

  def explain level = 0
    str  = " " * level + criteria + ":\n"
    str += @ops.collect { |op| op.explain(level + 4) }.join(" " * level + operator + "\n")
    str
  end  
end

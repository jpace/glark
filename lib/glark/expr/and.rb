#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/expr/compound'

# Evaluates both expressions, and is satisfied when both return true.
class AndExpression < CompoundExpression
  
  def initialize dist, op1, op2
    @dist = dist
    super op1, op2
  end

  def mark_as_match infile
    infile.mark_as_match start_position, end_position
  end

  def match_within_distance op, lnum
    info "op: #{op}; lnum: #{lnum}"
    op.matches.size > 0 and (op.matches[-1] - lnum <= @dist)
  end

  def inspect
    str = "("+ @ops[0].to_s
    if @dist == 0
      str += " same line as "
    elsif @dist.kind_of?(Float) && @dist.infinite?
      str += " same file as "
    else 
      str += " within " + @dist.to_s + " lines of "
    end
    str += @ops[1].to_s + ")"
    str
  end

  def match? line, lnum, file
    matches = (0 ... @ops.length).select do |oi|
      @ops[oi].evaluate line, lnum, file
    end

    matches.each do |mi|
      oidx  = (1 + mi) % @ops.length
      other = @ops[oidx]
      if match_within_distance other, lnum
        # search for the maximum match within the distance limit
        other.matches.each do |m|
          if lnum - m <= @dist
            log { "match: #{m} within range #{@dist} of #{lnum}" }
            @last_start = m
            return true
          end
        end
        log { "other matches out of range" }
        return false
      end
    end

    false
  end
  
  def end_position
    @ops.collect { |op| op.end_position }.max
  end

  def evaluate line, lnum, file
    if match? line, lnum, file
      @match_line_number = lnum
      true
    else
      false
    end
  end

  def explain level = 0
    str = ""
    if @dist == 0
      str += " " * level + "on the same line:\n"
    elsif @dist.kind_of?(Float) && @dist.infinite?
      str += " " * level + "in the same file:\n"
    else 
      lnstr = @dist == 1 ? "line" : "lines"
      str += " " * level + "within #{@dist} #{lnstr} of each other:\n"
    end
    str += @ops[0].explain(level + 4)
    str += " " * level + "and\n"
    str += @ops[1].explain(level + 4)
    str
  end
  
end

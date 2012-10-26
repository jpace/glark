#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Extended regular-expression-based expressions.

require 'rubygems'
require 'riel'
require 'glark/app/options'
require 'glark/range'

# A function object, which can be applied (processed) against a InputFile.
class FuncObj
  include Loggable
  
  attr_accessor :match_line_number, :file, :matches, :invert_match

  def initialize
    @match_line_number = nil
    @matches           = Array.new
    
    opts               = Glark::Options.instance
    @invert_match      = opts.invert_match
    @display_matches   = !opts.file_names_only && opts.filter && !opts.count
    @range             = opts.range
    @file_names_only   = opts.file_names_only
    @match_limit       = opts.match_limit
    @write_null        = opts.write_null
    @filter            = opts.filter
  end

  def add_match lnum
    @matches.push lnum
  end

  def start_position
    match_line_number
  end

  def end_position
    start_position
  end

  def reset_file file
    @match_line_number = nil
    @file              = file
    @matches           = Array.new
  end

  def process infile
    got_match = false
    reset_file infile.fname
    
    rgstart  = @range && @range.to_line(@range.from, infile.linecount)
    info "rgstart: #{rgstart}".yellow
    rgend    = @range && @range.to_line(@range.to,   infile.linecount)
    info "rgend: #{rgend}".yellow
    
    lastmatch = 0
    nmatches = 0
    lnum = 0
    infile.each_line do |line|
      info "line: #{line.chomp}".cyan
      info "lnum: #{lnum}".cyan
      if ((!rgstart || lnum >= rgstart) && 
          (!rgend   || lnum <= rgend)   &&
          evaluate(line, lnum, infile))
        
        mark_as_match infile
        got_match = true
        nmatches += 1
        
        if @display_matches
          infile.write_matches !@invert_match, lastmatch, lnum
          lastmatch = lnum + 1
        elsif @file_names_only
          # we don't need to match more than once
          break
        end
        
        if @match_limit && nmatches >= @match_limit
          # we've found the match limit
          break
        end
      end
      lnum += 1
    end
    
    if @file_names_only
      if got_match != @invert_match
        if @write_null
          print infile.fname + "\0"
        else
          puts infile.fname
        end
      end
    elsif @filter
      if @invert_match
        infile.write_matches false, 0, lnum
      elsif got_match
        infile.write_matches true, 0, lnum
      end
    else
      infile.write_all
    end
  end

  def mark_as_match infile
    infile.mark_as_match start_position
  end

  def to_s
    str = inspect
  end
  
end


# -------------------------------------------------------
# Regular expression function object
# -------------------------------------------------------

# Applies a regular expression against a File.
class RegexpFuncObj < FuncObj
  attr_reader :re

  def initialize re, hlidx, args = Hash.new
    @re              = re
    @file            = nil
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

  def <=> other
    @re <=> other.re
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

  def evaluate line, lnum, file
    if Log.verbose
      log { "evaluating <<<#{line[0 .. -2]}>>>" }
    end
    
    if md = match?(line)
      log { "matched" }
      if @extract_matches
        if md.kind_of? MatchData
          line.replace md[-1] + "\n"
        else
          warn "--not does not work with -v"
        end
      else
        # log { "NOT replacing line" }
      end
      
      @match_line_number = lnum

      if @highlight
        highlight_match lnum, file
      end
      
      add_match lnum
      true
    else
      false
    end
  end
  
  def explain level = 0
    " " * level + to_s + "\n"
  end

  def highlight_match lnum, file
    log { "lnum: #{lnum}; file: #{file}" }
    
    lnums = file.get_range lnum
    log { "lnums(#{lnum}): #{lnums}" }
    if lnums
      lnums.each do |ln|
        str = file.output.formatted[ln] || file.get_line(ln)
        if Log.verbose
          log { "file.output.formatted[#{ln}]: #{file.output.formatted[ln]}" }
          log { "file.get_line(#{ln}): #{file.get_line(ln)}" }
          log { "highlighting: #{str}" }
        end
        
        file.output.formatted[ln] = str.gsub(@re) do |m|
          lastcapts = Regexp.last_match.captures
          # find the index of the first non-nil capture:
          miidx = (0 ... lastcapts.length).find { |mi| lastcapts[mi] } || @hlidx
          
          @text_highlights[miidx].highlight m
        end
      end
    end
  end
  
end


# -------------------------------------------------------
# Compound expression function object
# -------------------------------------------------------

# Associates a pair of expressions.
class CompoundExpression < FuncObj

  attr_reader :ops

  def initialize(*ops)
    @ops  = ops
    @file = nil
    super()
  end

  def reset_file file
    @ops.each do |op|
      op.reset_file file
    end
    super
  end

  def start_position
    @last_start
  end
  
  def == other
    self.class == other.class && @ops == other.ops
  end
  
end


# -------------------------------------------------------
# Multi-Or expression function object
# -------------------------------------------------------

# Evaluates both expressions.
class MultiOrExpression < CompoundExpression

  def evaluate line, lnum, file
    matched_ops = @ops.select do |op|
      op.evaluate line, lnum, file
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


# -------------------------------------------------------
# Inclusive or expression function object
# -------------------------------------------------------

# Evaluates the expressions, and is satisfied when one return true.
class InclusiveOrExpression < MultiOrExpression

  def is_match? matched_ops
    return matched_ops.size > 0
  end

  def operator
    "or"
  end

  def criteria
    ops.size == 2 ? "either" : "any of"
  end

end


# -------------------------------------------------------
# Exclusive or expression function object
# -------------------------------------------------------

# Evaluates the expressions, and is satisfied when only one returns true.
class ExclusiveOrExpression < MultiOrExpression

  def is_match? matched_ops
    return matched_ops.size == 1
  end

  def operator
    "xor"
  end

  def criteria
    "only one of"
  end

end


# -------------------------------------------------------
# And expression function object
# -------------------------------------------------------

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
    stack "op: #{op}; lnum: #{lnum}"
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

    return false
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

#!/usr/bin/ruby -w
# -*- ruby -*-

module Glark; end

class Glark::RangeError < RuntimeError
end

class Glark::Range
  include Loggable, Comparable

  PCT_RE = Regexp.new '([\.\d]+)%'
  
  attr_accessor :from
  attr_accessor :to

  def initialize from = nil, to = nil
    @from = from
    @to = to
  end

  def to_line var, linecount
    info "var: #{var}".on_red
    if var
      if md = PCT_RE.match(var) 
        count = linecount
        count * md[1].to_f / 100
      else
        var.to_f
      end
    else
      nil
    end
  end

  def valid?
    return true if @from.nil? || @to.nil?

    smd = PCT_RE.match @from
    emd = PCT_RE.match @to

    # both or neither are percentages:
    return true if smd.nil? != emd.nil?

    if smd
      check_range smd[1], emd[1]
    else
      check_range @from, @to
    end
  end

  def check_range from, to
    if from.to_f > to.to_f
      raise Glark::RangeError.new "error: range start (#{@from}) follows range end (#{@to})"
    end
  end

  # there is no nil <=> nil in Ruby
  def compare x, y
    x.nil? && y.nil? ? nil : (x <=> y).nonzero?
  end

  def <=> other
    compare(from, other.from) || compare(to, other.to) || 0
  end
end

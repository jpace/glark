#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'

module Glark
  class RangeError < RuntimeError
  end

  class Range
    include Logue::Loggable, Comparable

    PCT_RE = Regexp.new '([\.\d]+)%'
    
    attr_accessor :from
    attr_accessor :to

    def initialize from = nil, to = nil
      @from = from
      @to = to
    end

    def bound?
      @from.nil? && @to.nil?
    end

    def to_line var, linecount
      return nil unless var

      if pct = as_pct(var) 
        count = linecount
        count * pct.to_f / 100
      else
        var.to_f
      end
    end

    def as_pct val
      (md = PCT_RE.match(val)) && md[1]
    end

    def validate!
      return true if @from.nil? || @to.nil?

      frompct, topct = [ @from, @to ].collect { |val| as_pct val }

      # both or neither are percentages:
      return true if frompct.nil? != topct.nil?
      
      if frompct
        check_range! frompct, topct
      else
        check_range! @from, @to
      end
      true
    end

    def check_range! from, to
      if from.to_f > to.to_f
        raise RangeError.new "error: range start (#{@from}) follows range end (#{@to})"
      end
    end

    # there is no nil <=> nil in Ruby
    def compare x, y
      x.nil? && y.nil? ? nil : (x <=> y).nonzero?
    end

    def <=> other
      compare(from, other.from) || compare(to, other.to) || 0
    end

    def clear
      @from = nil
      @to = nil
    end

    def add_as_option optdata
      optdata << {
        :tags => %w{ --after },
        :arg => [ :required, :regexp, %r{ (\d+%?) $ }x ],
        :set => Proc.new { |md| @from = md }
      }

      optdata << { 
        :tags => %w{ --before },
        :arg => [ :required, :regexp, %r{ (\d+%?) $ }x ],
        :set => Proc.new { |md| @to = md }
      }

      optdata << {
        :tags => %w{ -R --range },
        :arg => [ :required, :regexp, Regexp.new('(\d+%?,\d+%?)') ],
        :set => Proc.new { |md, opt, args| @from, @to = md.split(',') }
      }
    end
  end
end

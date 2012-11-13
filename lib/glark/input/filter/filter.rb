#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'riel/log'

class Filter
  include Loggable

  def match? pn
  end
end

class PatternFilter
  include Loggable

  attr_reader :pattern

  def initialize pattern
    @pattern = pattern
  end

  def pattern_match? str
    @pattern.match str
  end

  def to_s
    @pattern.to_s
  end
end

class BaseNameFilter < PatternFilter
  def match? pn
    pattern_match? pn.basename.to_s
  end
end

class FullNameFilter < PatternFilter
  def match? pn
    pattern_match? pn.to_s
  end
end

class SizeLimitFilter < Filter
  attr_reader :max_size
  
  def initialize maxsize
    @max_size = maxsize
  end

  def match? pn
    pn.size > @max_size
  end
end

class ExtFilter < PatternFilter
  def match? pn
    pattern_match? pn.extname.to_s[1 .. -1]
  end
end

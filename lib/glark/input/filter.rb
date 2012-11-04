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

  def initialize pattern
    @pattern = pattern
  end
end

class BaseNameFilter < PatternFilter
  def match? pn
    @pattern.match pn.basename.to_s
  end
end

class FullNameFilter < PatternFilter
  def match? pn
    @pattern.match pn.to_s
  end
end

class SizeLimitFilter < Filter
  def initialize maxsize
    @max_size = maxsize
  end

  def match? pn
    pn.size > @max_size
  end
end

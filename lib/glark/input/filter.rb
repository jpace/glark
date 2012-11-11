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

module FileFilter
  def match? pn
    pn.file?
  end
end

module DirectoryFilter
  def match? pn
    pn.file?
  end
end

class DirectoryPatternFilter < PatternFilter
  def match? pn
    pn.directory?
  end
end

class FilePatternFilter < PatternFilter
  def match? pn
    pn.file?
  end
end

class BaseNameFilter < PatternFilter
  def match? pn
    pattern_match? pn.basename.to_s
  end
end

class DirectoryBaseNameFilter < DirectoryPatternFilter
  def match? pn
    super && pattern_match?(pn.basename.to_s)
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

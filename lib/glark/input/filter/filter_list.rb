#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter'

module Glark; end

class Glark::FilterList
  include Loggable, Enumerable
  
  def initialize
    @filters = Array.new
  end

  def << filter
    @filters << filter
  end

  def empty?
    @filters.empty?
  end

  def match? pn
    @filters.detect { |filter| filter.match? pn }
  end

  def find_by_class cls
    @filters.detect { |filter| filter.kind_of? cls }
  end

  def each &blk
    @filters.each(&blk)
  end
end

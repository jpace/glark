#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter'

module Glark; end

class Glark::FilterList
  include Loggable, Enumerable
  
  def initialize
    @filters = Array.new

    # by type => by positive/negative => filter list
    @type_to_posneg = Hash.new
  end

  def << filter
    @filters << filter
  end

  def empty?
    @filters.empty?
  end

  def match? pn
    detect { |filter| filter.match? pn }
  end

  def find_by_class cls
    detect { |filter| filter.kind_of? cls }
  end

  def each &blk
    @filters.each(&blk)
  end

  def add type, posneg, filter
    # by type => by positive/negative => filter list
    @filters = Hash.new { |h, k| h[k] = Hash.new { |h1, k1| h1[k1] = Glark::FilterList.new } }

    posneg_to_filters = (@type_to_posneg[type] ||= Hash.new)
    filters = (posneg_to_filters[posneg] ||= Array.new)
    filters << filter
  end
end

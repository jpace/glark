#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter'

module Glark; end

class Glark::FilterList
  include Loggable, Enumerable
  
  def initialize
    # by type (hash) => by positive/negative (hash) => filter list (array)
    @type_to_posneg = Hash.new
  end

  def empty?
    @type_to_posneg.empty?
  end

  def find_by_class type, posneg, cls
    return unless filters = get(type, posneg)
    filters.detect { |filter| filter.kind_of? cls }
  end

  def add type, posneg, filter
    posneg_to_filters = (@type_to_posneg[type] ||= Hash.new)
    filters = (posneg_to_filters[posneg] ||= Array.new)
    filters << filter
  end

  def get_all
    @type_to_posneg
  end

  def get type, posneg
    return nil unless posneg_to_filters = @type_to_posneg[type]
    posneg_to_filters[posneg]
  end

  def match? type, posneg, pn
    return nil unless filters = get(type, posneg)
    return nli if filters.empty?

    filters.detect { |fl| fl.match? pn }
  end
end

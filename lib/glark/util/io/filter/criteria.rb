#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'rubygems'
require 'logue/loggable'
require 'glark/util/io/filter/filter'

module Glark
  class Criteria
    include Logue::Loggable

    def initialize
      # by type (hash) => by positive/negative (hash) => filter list (array)
      @type_to_posneg = Hash.new
    end

    def add type, posneg, filter
      posneg_to_filters = (@type_to_posneg[type] ||= Hash.new)
      filters = (posneg_to_filters[posneg] ||= Array.new)
      filters << filter
    end

    def get type, posneg
      return nil unless posneg_to_filters = @type_to_posneg[type]
      posneg_to_filters[posneg]
    end

    def find_by_class type, posneg, cls
      return unless filters = get(type, posneg)
      filters.detect { |filter| filter.kind_of? cls }
    end
    
    def skipped? pn
      !match? pn
    end

    def match? pn
      @type_to_posneg.values.each do |typefilters|
        if (posf = typefilters[:positive]) && !posf.empty?
          return false unless posf.detect { |fl| fl.match? pn }
        end

        if (negf = typefilters[:negative]) && !negf.empty?
          return false if negf.detect { |fl| fl.match? pn }
        end
      end
      true
    end
  end
end

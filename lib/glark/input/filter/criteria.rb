#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter_list'

module Glark; end

class Glark::Criteria
  include Loggable

  attr_reader :filters
  
  def initialize
    # by type => by positive/negative => filter list
    @filters = Hash.new { |h, k| h[k] = Hash.new { |h1, k1| h1[k1] = Glark::FilterList.new } }
  end

  def add type, posneg, filter
    @filters[type][posneg] << filter
  end

  def match? pn
    @filters.each do |type, typefilters|
      if (posf = typefilters[:positive]) && !posf.empty?
        return false unless posf.match? pn
      end

      if (negf = typefilters[:negative]) && !negf.empty?
        return false if negf.match? pn
      end
    end
    true
  end
end

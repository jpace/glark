#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter_list'

module Glark; end

class Glark::Criteria
  include Loggable

  attr_reader :filter_list
  
  def initialize
    @filter_list = Glark::FilterList.new
  end

  def add type, posneg, filter
    @filter_list.add type, posneg, filter
  end

  def match? pn
    filters = @filter_list.get_all
    filters.values.each do |typefilters|
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

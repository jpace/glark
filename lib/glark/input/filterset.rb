#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter'
require 'glark/input/filters'

module Glark; end

class Glark::FilterSet
  include Loggable
  
  def initialize
    @positive_filters = Glark::Filters.new
    @negative_filters = Glark::Filters.new
  end

  def add_positive_filter filter
    @positive_filters << filter
  end

  def add_negative_filter filter
    @negative_filters << filter
  end

  def skipped? pn
    return true if !@positive_filters.empty? && !@positive_filters.match?(pn)
    @negative_filters.match? pn
  end
end

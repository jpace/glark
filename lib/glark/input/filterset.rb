#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter'

module Glark; end

class Glark::FilterSet
  def initialize
    @positive_filters = Array.new
    @negative_filters = Array.new
  end

  def add_positive_filter filter
    @positive_filters << filter
  end

  def add_negative_filter filter
    @negative_filters << filter
  end

  def skipped? fname
    pn = Pathname.new fname
    @positive_filters.each do |filter|
      unless filter.match? pn
        return true
      end
    end

    @negative_filters.each do |filter|
      if filter.match? pn
        return true
      end
    end

    false
  end
end

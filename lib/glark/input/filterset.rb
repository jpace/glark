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

  def add_filter posneg, cls, field
    var = instance_variable_get '@' + posneg.to_s + '_filters'
    var << cls.new(field)
  end

  def add_filters posneg, cls, field
    return unless field

    if field.kind_of? Array
      field.each do |fld|
        add_filter posneg, cls, fld
      end
    else
      add_filter posneg, cls, field
    end
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter'
require 'glark/input/filters'

module Glark; end

class Glark::FilterSet
  include Loggable

  attr_reader :positive
  attr_reader :negative
  
  def initialize
    @positive = Glark::Filters.new
    @negative = Glark::Filters.new
  end

  def add_positive_filter filter
    @positive << filter
  end

  def add_negative_filter filter
    @negative << filter
  end

  def skipped? pn
    return true if !@positive.empty? && !@positive.match?(pn)
    @negative.match? pn
  end

  def add_filter posneg, cls, field
    var = instance_variable_get '@' + posneg.to_s
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

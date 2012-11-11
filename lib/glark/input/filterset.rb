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

  def add_opt_filter_int optdata, tags, posneg, cls
    optdata << {
      :tags => tags,
      :arg  => [ :integer ],
      :set  => Proc.new { |val| add_filter posneg, cls, val.to_i }
    }
  end

  def add_opt_filter_re optdata, tags, posneg, cls
    optdata << {
      :tags => tags,
      :arg  => [ :string ],
      :set  => Proc.new { |pat| add_filter posneg, cls, Regexp.create(pat) }
    }
  end

  def config_fields
    fields = {
    }
  end

  def dump_fields
    config_fields
  end

  def update_fields fields
  end
end

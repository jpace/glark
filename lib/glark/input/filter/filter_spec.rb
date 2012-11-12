#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter'
require 'glark/input/filter/filter_list'

module Glark; end

class Glark::FilterSpec
  include Loggable

  attr_reader :positive
  attr_reader :negative
  
  def initialize
    @positive = Glark::FilterList.new
    @negative = Glark::FilterList.new
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

  def add_filters posneg, cls, values
    values.each do |val|
      add_filter posneg, cls, Regexp.create(val)
    end
  end
  
  def add_filter_by_re re, name, values
    return false unless md = re.match(name)

    posneg = md[1] == 'match' ? :positive : :negative
    cls    = md[2] == 'path'  ? FullNameFilter : BaseNameFilter
    add_filters posneg, cls, values
    true
  end
end

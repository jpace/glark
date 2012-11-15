#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter'
require 'glark/input/filter/filter_list'
require 'glark/input/filter/criteria'

module Glark; end

class Glark::FilterSpec
  include Loggable

  attr_reader :positive
  attr_reader :negative

  attr_reader :criteria
  
  def initialize
    @positive = Glark::FilterList.new
    @negative = Glark::FilterList.new

    @criteria = Glark::Criteria.new
  end

  def orig_skipped? pn
    return true if !@positive.empty? && !@positive.match?(pn)
    @negative.match? pn
  end

  def skipped? pn
    !@criteria.match? pn
  end

  def add_filter field, posneg, cls, criteria
    info "field   : #{field}".cyan
    info "posneg  : #{posneg}"
    info "cls     : #{cls}"
    info "criteria: #{criteria}"
    # var = instance_variable_get '@' + posneg.to_s
    # var << cls.new(criteria)

    @criteria.add field, posneg, cls.new(criteria)
  end

  def add_opt_filter_int optdata, tags, field, posneg, cls
    optdata << {
      :tags => tags,
      :arg  => [ :integer ],
      :set  => Proc.new { |val| add_filter field, posneg, cls, val.to_i }
    }
  end

  def add_opt_filter_re optdata, tags, field, posneg, cls
    optdata << {
      :tags => tags,
      :arg  => [ :string ],
      :set  => Proc.new { |pat| add_filter field, posneg, cls, Regexp.create(pat) }
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

  def add_filters field, posneg, cls, values
    values.each do |val|
      add_filter field, posneg, cls, Regexp.create(val)
    end
  end
  
  def add_filter_by_re re, name, values
    return false unless md = re.match(name)

    posneg = md[1] == 'match' ? :positive : :negative
    field, cls = case md[2]
                 when 'path'
                   [ :path, FullNameFilter ]
                 when 'name'
                   [ :name, BaseNameFilter ]
                 when 'ext'
                   [ :ext, ExtFilter ]
                 end
    info "field: #{field}".yellow
    info "cls: #{cls}".yellow
    info "posneg: #{posneg}"
    add_filters field, posneg, cls, values
    true
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter'
require 'glark/input/filter/criteria'

module Glark; end

class Glark::FilterSpec
  include Loggable

  attr_reader :criteria
  
  def initialize
    @criteria = Glark::Criteria.new
  end

  def skipped? pn
    !@criteria.match? pn
  end

  def add_opt_filter_int optdata, opt
    @criteria.add_opt_filter_int optdata, opt
  end

  def add_opt_filter_pat optdata, opt
    @criteria.add_opt_filter_pat optdata, opt
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
    @criteria.add_filters field, posneg, cls, values
  end
  
  def process_rcfields rcfields, options
    rcfields.each do |name, values|
      options.each do |opt|
        posneg = case name
                 when opt[:posrc]
                   :positive
                 when opt[:negrc]
                   :negative
                 else
                   next
                 end
        
        add_filters opt[:field], posneg, opt[:cls], values
      end
    end
  end
end

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

  def add_filter field, posneg, cls, criteria
    @criteria.add field, posneg, cls.new(criteria)
  end

  def add_opt_filter_int optdata, opt
    optdata << {
      :tags => opt[:tags],
      :arg  => [ :integer ],
      :set  => Proc.new { |val| add_filter opt[:field], opt[:posneg], opt[:cls], val.to_i }
    }
  end

  def add_opt_filter_pat optdata, opt
    [ [ opt[:postags], :positive ], 
      [ opt[:negtags], :negative ] ].each do |tags, posneg|
      next unless tags
      optdata << {
        :tags => tags,
        :arg  => [ :string ],
        :set  => Proc.new { |pat| add_filter opt[:field], posneg, opt[:cls], Regexp.create(pat) }
      }
    end
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

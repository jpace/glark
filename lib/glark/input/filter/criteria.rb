#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

module Glark; end

class Glark::Criteria
  include Loggable

  def initialize
    # by type (hash) => by positive/negative (hash) => filter list (array)
    @type_to_posneg = Hash.new
    @options = opt_classes.collect { |optcls| optcls.new self }
  end

  def opt_classes
    Array.new
  end

  def add type, posneg, filter
    posneg_to_filters = (@type_to_posneg[type] ||= Hash.new)
    filters = (posneg_to_filters[posneg] ||= Array.new)
    filters << filter
  end

  def get type, posneg
    return nil unless posneg_to_filters = @type_to_posneg[type]
    posneg_to_filters[posneg]
  end

  def find_by_class type, posneg, cls
    return unless filters = get(type, posneg)
    filters.detect { |filter| filter.kind_of? cls }
  end
  
  def skipped? pn
    !match? pn
  end

  def match? pn
    @type_to_posneg.values.each do |typefilters|
      if (posf = typefilters[:positive]) && !posf.empty?
        return false unless posf.detect { |fl| fl.match? pn }
      end

      if (negf = typefilters[:negative]) && !negf.empty?
        return false if negf.detect { |fl| fl.match? pn }
      end
    end
    true
  end

  def config_fields
    fields = {
    }
  end

  def dump_fields
    config_fields
  end

  def update_fields rcfields
    rcfields.each do |name, values|
      @options.each do |opt|
        opt.match_rc name, values
      end
    end
  end

  def add_as_options optdata
    @options.each do |opt|
      opt.add_to_option_data optdata
    end
  end
end

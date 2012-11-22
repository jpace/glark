#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

module Glark; end

class Glark::Criteria
  include Loggable

  def initialize
    # by type (hash) => by positive/negative (hash) => filter list (array)
    @type_to_posneg = Hash.new
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

  def add_opt_filter_int optdata, opt
    optdata << {
      :tags => opt[:tags],
      :arg  => [ :integer ],
      :set  => Proc.new { |val| add opt[:field], opt[:posneg], opt[:cls].new(val.to_i) }
    }
  end

  def add_opt_filter_pat optdata, opt
    [ [ opt[:postags], :positive ], 
      [ opt[:negtags], :negative ] ].each do |tags, posneg|
      next unless tags
      optdata << {
        :tags => tags,
        :arg  => [ :string ],
        :set  => Proc.new { |pat| add opt[:field], posneg, opt[:cls].new(Regexp.create pat) }
      }
    end
  end

  def add_filters field, posneg, cls, values
    values.each do |val|
      add field, posneg, cls.new(Regexp.create val)
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

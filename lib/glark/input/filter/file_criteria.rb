#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/criteria'
require 'glark/input/filter/filter'
require 'glark/util/optutil'

module Glark; end

class Glark::FileCriteria < Glark::Criteria
  include Glark::OptionUtil
  
  def initialize 
    super

    @szlimit_opt = { :tags => %w{ --size-limit }, :negrc => 'size-limit', :field => :size, :posneg => :negative, :cls => SizeLimitFilter }

    @basename_opt = { :field => :name, :cls => BaseNameFilter }
    @basename_opt[:postags] = %w{ --basename --name --with-basename --with-name --match-name }
    @basename_opt[:negtags] = %w{ --without-basename --without-name --not-name }
    @basename_opt[:posrc] = 'match-name'
    @basename_opt[:negrc] = 'not-name'
    
    @pathname_opt = { :field => :path, :cls => FullNameFilter }
    @pathname_opt[:postags] = %w{ --fullname --path --with-fullname --with-path --match-path }
    @pathname_opt[:negtags] = %w{ --without-fullname --without-path --not-path }
    @pathname_opt[:posrc] = 'match-path'
    @pathname_opt[:negrc] = 'not-path'

    @ext_opt = { :field => :ext, :cls => ExtFilter }
    @ext_opt[:postags] = %w{ --match-ext }
    @ext_opt[:negtags] = %w{ --not-ext }
    @ext_opt[:posrc] = 'match-ext'
    @ext_opt[:negrc] = 'not-ext'
  end

  def add_as_options optdata
    add_opt_filter_int optdata, @szlimit_opt

    add_opt_filter_pat optdata, @basename_opt
    add_opt_filter_pat optdata, @pathname_opt
    add_opt_filter_pat optdata, @ext_opt
  end

  def config_fields
    maxsize = (filter = find_by_class(:size, :negative, SizeLimitFilter)) && filter.max_size
    fields = {
      "size-limit" => maxsize
    }
  end

  def update_fields rcfields
    process_rcfields rcfields, [ @basename_opt, @pathname_opt, @ext_opt ]

    rcfields.each do |name, values|
      if name == @szlimit_opt[:negrc]
        add @szlimit_opt[:field], @szlimit_opt[:posneg], @szlimit_opt[:cls].new(values.last.to_i)
      end
    end
  end
end

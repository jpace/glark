#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter_spec'
require 'glark/util/optutil'

module Glark; end

class Glark::DirFilterSpec < Glark::FilterSpec
  include Glark::OptionUtil

  def initialize 
    super

    @basename_opt = { :field => :name, :cls => BaseNameFilter }
    @basename_opt[:postags] = %w{ --match-dirname }
    @basename_opt[:negtags] = %w{ --not-dirname }
    @basename_opt[:posrc] = 'match-dirname'
    @basename_opt[:negrc] = 'not-dirname'
    
    @pathname_opt = { :field => :path, :cls => FullNameFilter }
    @pathname_opt[:postags] = %w{ --match-dirpath }
    @pathname_opt[:negtags] = %w{ --not-dirpath }
    @pathname_opt[:posrc] = 'match-dirpath'
    @pathname_opt[:negrc] = 'not-dirpath'

    add_filter :name, :negative, BaseNameFilter, '.svn'
  end

  def add_as_options optdata
    add_opt_filter_pat optdata, @basename_opt
    add_opt_filter_pat optdata, @pathname_opt
  end

  def update_fields rcfields
    process_rcfields rcfields, [ @basename_opt, @pathname_opt ]
  end
end

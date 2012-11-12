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
    add_filter :negative, BaseNameFilter, '.svn'
  end

  def add_as_options optdata
    # match/skip files by basename
    add_opt_filter_re optdata, %w{ --match-dirname }, :positive, BaseNameFilter
    add_opt_filter_re optdata, %w{ --not-dirname }, :negative, BaseNameFilter

    # match/skip files by pathname
    add_opt_filter_re optdata, %w{ --match-dirpath }, :positive, FullNameFilter
    add_opt_filter_re optdata, %w{ --not-dirpath }, :negative, FullNameFilter
  end

  def update_fields fields
    re = Regexp.new '^(match|not)-dir(path|name)$'
    fields.each do |name, values|
      add_filter_by_re re, name, values
    end
  end
end

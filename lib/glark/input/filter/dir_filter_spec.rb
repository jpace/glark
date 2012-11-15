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
    add_filter :name, :negative, BaseNameFilter, '.svn'
  end

  def add_as_options optdata
    # match/skip files by basename
    add_opt_filter_re optdata, %w{ --match-dirname }, :name, :positive, BaseNameFilter
    add_opt_filter_re optdata, %w{ --not-dirname }, :name, :negative, BaseNameFilter

    # match/skip files by pathname
    add_opt_filter_re optdata, %w{ --match-dirpath }, :path, :positive, FullNameFilter
    add_opt_filter_re optdata, %w{ --not-dirpath }, :path, :negative, FullNameFilter
  end

  def update_fields fields
    re = Regexp.new '^(match|not)-dir(path|name)$'
    fields.each do |name, values|
      add_filter_by_re re, name, values
    end
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/filter_spec'
require 'glark/util/optutil'

module Glark; end

class Glark::FileFilterSpec < Glark::FilterSpec
  include Glark::OptionUtil
  
  def initialize 
    super

    @szlimit = { :tags => %w{ --size-limit }, :rcfield => 'size-limit', :field => :size, :posneg => :negative, :cls => SizeLimitFilter }

    @basename = { :field => :name, :cls => BaseNameFilter }

    @match_basename = @basename.dup
    @match_basename[:tags] = %w{ --basename --name --with-basename --with-name --match-name }
    @match_basename[:posneg] = :positive

    @not_basename = @basename.dup
    @not_basename[:tags] = %w{ --without-basename --without-name --not-name }
    @not_basename[:posneg] = :negative

    @pathname = { :field => :path, :cls => FullNameFilter }

    @match_pathname = @pathname.dup
    @match_pathname[:tags] = %w{ --fullname --path --with-fullname --with-path --match-path }
    @match_pathname[:posneg] = :positive

    @not_pathname = @pathname.dup
    @not_pathname[:tags] = %w{ --without-fullname --without-path --not-path }
    @not_pathname[:posneg] = :negative

    @ext = { :field => :ext, :cls => ExtFilter }

    @match_ext = @ext.dup
    @match_ext[:tags] = %w{ --match-ext }
    @match_ext[:posneg] = :positive

    @not_ext = @ext.dup
    @not_ext[:tags] = %w{ --not-ext }
    @not_ext[:posneg] = :negative

    @ext_filters = Array.new
  end

  def add_as_options optdata
    add_opt_filter_int optdata, @szlimit

    # match/skip files by basename
    add_opt_filter_pat optdata, @match_basename
    add_opt_filter_pat optdata, @not_basename

    # match/skip files by pathname
    add_opt_filter_pat optdata, @match_pathname
    add_opt_filter_pat optdata, @not_pathname

    add_opt_filter_pat optdata, @match_ext
    add_opt_filter_pat optdata, @not_ext
  end

  def config_fields
    fields = {
      "size-limit" => (filter = @negative_filters.find_by_class(SizeLimitFilter) && filter.max_size),
    }
  end

  def update_fields fields
    re = Regexp.new '^(match|not)-(path|name|ext)$'
    fields.each do |name, values|
      next if add_filter_by_re re, name, values

      if name == @szlimit[:rcfield]
        add_filter @szlimit[:field], @szlimit[:posneg], @szlimit[:cls], values.last.to_i
      end
    end
  end
end

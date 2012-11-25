#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/criteria_opts'
require 'glark/input/filter/filter'
require 'glark/input/filter/options'
require 'glark/util/optutil'

module Glark; end

class Glark::FileCriteriaOpts < Glark::CriteriaOpts
  include Glark::OptionUtil

  def opt_classes
    [
     Glark::SizeLimitOption,
     Glark::MatchNameOption,
     Glark::SkipNameOption,
     Glark::MatchPathOption,
     Glark::SkipPathOption,
     Glark::MatchExtOption,
     Glark::SkipExtOption,
    ]
  end

  def config_fields
    maxsize = (filter = find_by_class(:size, :negative, SizeLimitFilter)) && filter.max_size
    fields = {
      "size-limit" => maxsize
    }
  end
end

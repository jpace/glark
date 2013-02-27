#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/criteria_opts'
require 'glark/input/filter/filter'
require 'glark/input/filter/options'
require 'glark/util/optutil'

module Glark
  class FileCriteriaOpts < CriteriaOpts
    include OptionUtil

    def opt_classes
      [
       SizeLimitOption,
       MatchNameOption,
       SkipNameOption,
       MatchPathOption,
       SkipPathOption,
       MatchExtOption,
       SkipExtOption,
      ]
    end

    def config_fields
      maxsize = (filter = find_by_class(:size, :negative, SizeLimitFilter)) && filter.max_size
      {
        "size-limit" => maxsize
      }
    end
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/criteria_opts'
require 'glark/input/filter/options'
require 'glark/util/optutil'

module Glark
  class DirCriteriaOpts < CriteriaOpts
    include OptionUtil

    attr_accessor :skip_all

    def initialize skip_all
      super()
      @skip_all = skip_all
      
      add :name, :negative, BaseNameFilter.new('.svn')
      add :name, :negative, BaseNameFilter.new('.git')
    end

    def skipped? pn, depth
      return true if @skip_all || !depth.nonzero?
      super pn
    end

    def opt_classes
      [
       MatchDirNameOption,
       SkipDirNameOption,
       MatchDirPathOption,
       SkipDirPathOption,
      ]
    end
  end
end

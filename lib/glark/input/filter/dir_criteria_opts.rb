#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter/criteria_opts'
require 'glark/input/filter/options'
require 'glark/util/optutil'

module Glark; end

class Glark::DirCriteriaOpts < Glark::CriteriaOpts
  include Glark::OptionUtil

  def initialize 
    super
    add :name, :negative, BaseNameFilter.new('.svn')
    add :name, :negative, BaseNameFilter.new('.git')
  end

  def opt_classes
    [
     Glark::MatchDirNameOption,
     Glark::SkipDirNameOption,
     Glark::MatchDirPathOption,
     Glark::SkipDirPathOption,
    ]
  end
end

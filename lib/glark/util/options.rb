#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/util/optutil'

module Glark
  class Options
    include Loggable, Glark::OptionUtil
  end
end

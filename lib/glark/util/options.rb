#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/util/optutil'
require 'logue/loggable'

module Glark
  class Options
    include Logue::Loggable, Glark::OptionUtil
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/util/optutil'

module Glark
  class Options
    include Loggable, Glark::OptionUtil

    NONE = Object.new

    def set_var name, val
      instance_variable_set '@' + name.to_s, val
    end

    def set name, sval = NONE
      Proc.new { |optval| set_var name, sval == NONE ? optval : sval }
    end
  end
end

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

    def add_opt optdata, varname, tags, val = NONE
      optdata << {
        :tags => tags,
        :set  => set(varname, val)
      }
    end

    def add_opt_arg optdata, varname, argtype, tags, val = NONE
      optdata << {
        :tags => tags,
        :arg  => [ argtype ],
        :set  => set(varname, val)
      }
    end

    def add_opt_true optdata, varname, tags
      add_opt optdata, varname, tags, true
    end

    def add_opt_false optdata, varname, tags
      add_opt optdata, varname, tags, false
    end

    def add_opt_str optdata, varname, tags, val = NONE
      add_opt_arg optdata, varname, :string, tags, val
    end

    def add_opt_int optdata, varname, tags, val = NONE
      add_opt_arg optdata, varname, :integer, tags, val
    end
  end
end

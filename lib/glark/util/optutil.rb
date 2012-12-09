#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'riel/text/ansi/color'

module Glark
  module OptionUtil
    # returns whether the value matches a true value, such as "yes", "true", or "on".
    def to_boolean value
      [ "yes", "true", "on" ].include? value.downcase
    end

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

    def add_opt_blk optdata, tags, &blk
      optdata << {
        :tags => tags,
        :set  => blk
      }
    end

    def colorize field, str
      if field
        field + str + Text::Color::RESET
      else
        str
      end
    end
  end
end

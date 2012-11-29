#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/util/io/filter/criteria'

module Glark
  class CriteriaOpts < Criteria
    def initialize
      super
      @options = opt_classes.collect { |optcls| optcls.new self }
    end

    def opt_classes
      Array.new
    end

    def config_fields
      fields = {
      }
    end

    def dump_fields
      config_fields
    end

    def update_fields rcfields
      rcfields.each do |name, values|
        @options.each do |opt|
          opt.match_rc name, values
        end
      end
    end

    def add_as_options optdata
      @options.each do |opt|
        opt.add_to_option_data optdata
      end
    end
  end
end

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

module Glark
  class Option
    def initialize optee
      @optee = optee
    end

    def tags
      [ '--' + rcfield ]
    end  
    
    def match_rc name, values
      if name == rcfield
        values.each do |val|
          set val
        end
        true
      end
    end

    def add_to_option_data optdata
      optdata << {
        :tags => tags,
        :arg  => [ argtype ],
        :set  => Proc.new { |pat| set pat }
      }
    end
  end
end

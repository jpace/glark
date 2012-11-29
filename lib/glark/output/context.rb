#!/usr/bin/ruby -w
# -*- ruby -*-

module Glark
  class Context
    attr_accessor :after
    attr_accessor :before

    def initialize 
      @after = 0
      @before = 0
    end

    def clear
      @after = 0
      @before = 0
    end

    def update_fields fields
      fields.each do |name, values|
        case name
        when 'context'
          @after = @before = values.last.to_i
        when 'after', 'after-context'
          @after = values.last.to_i
        when 'before', 'before-context'
          @before = values.last.to_i 
        end
      end
    end

    def add_as_option optdata
      optdata << context_option = {
        :tags => %w{ -C --context },
        :res  => %r{ ^ - ([1-9]\d*) $ }x,
        :arg  => [ :optional, :integer ],
        :set  => Proc.new { |val, opt, args| @after = @before = val || 2 },
        :rc   => %w{ context },
      }

      optdata << context_after_option = {
        :tags => %w{ --after-context -A },
        :arg  => [ :integer ],
        :set  => Proc.new { |val| @after = val },
        :rc   => %w{ after-context },
      }

      optdata << context_before_option = {
        :tags => %w{ --before-context -B },
        :arg  => [ :integer ],
        :set  => Proc.new { |val| @before = val },
        :rc   => %w{ before-context },
      }
    end
  end
end


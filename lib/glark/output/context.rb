#!/usr/bin/ruby -w
# -*- ruby -*-

module Glark
  class Context
    include Logue::Loggable
    
    attr_accessor :after
    attr_accessor :before

    def initialize
      clear
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
      optdata << {
        :tags    => %w{ -C --context },
        :regexp  => %r{ ^ - ([1-9]\d*) $ }x,
        :arg     => [ :optional, :integer ],
        :process => Proc.new { |val, opt, args| @after = @before = val == true ? 2 : val },
        :rcname  => %w{ context },
      }

      optdata << {
        :tags => %w{ --after-context -A },
        :arg  => [ :integer ],
        :set  => Proc.new { |val| @after = val },
        :rc   => %w{ after-context },
      }

      optdata << {
        :tags => %w{ --before-context -B },
        :arg  => [ :integer ],
        :set  => Proc.new { |val| @before = val },
        :rc   => %w{ before-context },
      }
    end
  end
end

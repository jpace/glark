#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

module Glark
  # Depth for recursing directories.
  class Depth
    INFINITY = :infinity

    attr_reader :value
    
    def initialize value
      @value = value
    end

    def infinity?
      @value == INFINITY
    end

    def - num
      return self if infinity? || @value.nil?
      self.class.new @value - 1
    end

    def nonzero?
      infinity? || @value.nil? || @value >= 0
    end
  end
end

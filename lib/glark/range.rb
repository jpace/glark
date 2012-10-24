#!/usr/bin/ruby -w
# -*- ruby -*-

module Glark
  class Range
    attr_accessor :from
    attr_accessor :to

    def initialize from = nil, to = nil
      @from = from
      @to = to
    end
  end
end

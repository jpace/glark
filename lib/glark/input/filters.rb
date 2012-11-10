#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/input/filter'

module Glark; end

class Glark::Filters
  include Loggable
  
  def initialize
    @filters = Array.new
  end

  def << filter
    @filters << filter
  end

  def empty?
    @filters.empty?
  end

  def match? pn
    @filters.detect { |filter| filter.match? pn }
  end
end

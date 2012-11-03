#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module Glark; end

module Glark::OptionUtil
  # returns whether the value matches a true value, such as "yes", "true", or "on".
  def to_boolean value
    [ "yes", "true", "on" ].include? value.downcase
  end
end

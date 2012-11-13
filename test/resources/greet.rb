#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

class Greet
  def initialize name
    puts "hello, " + name
  end
end

Greet.new ARGV.shift || "world"

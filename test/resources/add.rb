#!/usr/bin/ruby -w
# -*- ruby -*-

class Adder
  def initialize x, y
    puts x.to_s + " + " + y.to_s + " = " + (x.to_i + y.to_i).to_s
  end
end

Adder.new ARGV.shift || 2, ARGV.shift || 2

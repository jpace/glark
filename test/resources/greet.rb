#!/usr/bin/ruby -w
# -*- ruby -*-

class Greet
  def initialize name
    puts "hello, " + name
  end
end

Greet.new ARGV.shift || "world"

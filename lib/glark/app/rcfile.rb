#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module Glark; end

class Glark::RCFile
  COMMENT_RE = Regexp.new '\s*#.*'
  NAME_VALUE_RE = Regexp.new '\s*[=:]\s*'
  
  attr_reader :names
  
  def initialize file
    @names = Array.new
    @values = Hash.new

    pn = file.kind_of?(Pathname) ? file : Pathname.new(file)
    
    return unless pn.exist?

    pn.each_line do |line|
      read_line line
    end
  end

  def read_line line
    line.sub! COMMENT_RE, ''
    line.chomp!
    return if line.empty?
    
    name, value = line.split NAME_VALUE_RE
    return unless name && value

    @names << name unless @names.include?(name)
    @values[name] = value
  end

  def value name
    @values[name]
  end

  def add name, value
    @values[name]
  end
end

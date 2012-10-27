#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

class Glark::Resource
  include Loggable
  
  RES_DIR = '/proj/org/incava/glark/test/resources/'
  
  def to_path basename
    RES_DIR + basename
  end

  def readlines basename
    ::IO.readlines to_path
  end
end

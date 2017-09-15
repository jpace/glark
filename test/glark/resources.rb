#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'logue/loggable'

module Glark
  class Resource
    include Logue::Loggable
    
    RES_DIR = '/opt/org/incava/glark/test/resources/'
    
    def to_path basename
      RES_DIR + basename
    end

    def readlines basename
      ::IO.readlines to_path
    end
  end
end

module Glark
  module Resources
    PROJ_DIR = '/opt/org/incava/glark'
    TEST_DIR = PROJ_DIR + '/test'
    RES_DIR = TEST_DIR + '/resources'
    
    def to_path basename
      RES_DIR + (basename[0] == "/" ? "" : "/") + basename
    end

    def readlines basename
      ::IO.readlines to_path
    end
  end
end

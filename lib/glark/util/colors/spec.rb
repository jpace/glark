#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel/log/loggable'

module Glark
  class ColorSpec
    include Loggable
    
    attr_accessor :text_colors
    attr_accessor :file_name_color
    attr_accessor :line_number_color
    
    def initialize
      @text_colors = Array.new
      @file_name_color = nil
      @line_number_color = nil
    end
  end
end

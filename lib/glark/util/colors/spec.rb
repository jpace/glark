#!/usr/bin/ruby -w
# -*- ruby -*-

module Glark
  class ColorSpec
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

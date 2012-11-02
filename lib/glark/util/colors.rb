#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

class Glark::Colors
  include Loggable
  
  attr_accessor :highlighter
  attr_accessor :text_highlights
  attr_accessor :file_highlight
  attr_accessor :line_number_highlight

  def initialize hl = nil
    @highlighter = nil
    @text_highlights = Array.new
    @file_highlight = nil
    @line_number_highlight = nil
  end

  # creates a color for the given option, based on its value
  def make_highlight opt, value
    if @highlighter
      if value
        @highlighter.make value
      else
        raise "error: '" + opt + "' requires a color"
      end
    else
      log { "no highlighter defined" }
    end
  end

  def make_colors limit = -1
    Text::Highlighter::DEFAULT_COLORS[0 .. limit].collect { |color| @highlighter.make color }
  end

  def multi_colors 
    make_colors
  end

  def single_color
    make_colors 0
  end
end

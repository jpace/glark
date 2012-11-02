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
  attr_reader :text_color_style # single, multi, or nil (no text highlights)

  def initialize hl = nil
    @highlighter = nil
    @text_highlights = Array.new
    @file_highlight = nil
    @line_number_highlight = nil
    @text_color_style = "multi"
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

  def text_color_style= tcstyle
    @text_color_style = tcstyle
  end

  def highlight_multi? str
    %w{ multi on true yes }.detect { |x| str == x }
  end

  def clear
    @text_highlights = Array.new
    @file_highlight = nil
    @line_number_highlight = nil
  end

  def set
    @text_highlights = case @text_color_style
                       when highlight_multi?(@text_color_style), true
                         multi_colors
                       when "single"
                         single_color
                       else
                         raise "highlight format '" + @text_color_style.to_s + "' not recognized"
                       end
    @file_highlight = @highlighter.make "reverse bold"
    @line_number_highlight = nil
  end
end

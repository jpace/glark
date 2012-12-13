#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/util/colors/spec'

module Glark
  class ColorOptions < ColorSpec    
    attr_reader :text_color_style # single, multi, or nil (no text highlights)

    def initialize
      super
      @highlighter = nil
      @text_color_style = "multi"
    end

    # creates a color for the given option, based on its value
    def create_color opt, value
      if @highlighter
        if value
          make_color value
        else
          raise "error: '" + opt + "' requires a color"
        end
      else
        log { "no highlighter defined" }
      end
    end

    def make_color color
      @highlighter.make_color color
    end

    def make_rgb_color red, green, blue, fgbg
      @highlighter.make_rgb_color red, green, blue, fgbg
    end

    def make_colors limit = -1
      Text::Highlighter::DEFAULT_COLORS[0 .. limit].collect { |color| make_color color }
    end

    def multi_colors 
      make_colors
      # [ make_rgb_color(4, 3, 2, :bg) + make_rgb_color(0, 2, 1, :fg) ]
    end

    def single_color
      make_colors 0
    end

    def text_color_style= tcstyle
      @text_color_style = tcstyle
      if @text_color_style
        @highlighter = @text_color_style && HlWrapper.new
        @text_colors = case @text_color_style
                           when highlight_multi?(@text_color_style), true
                             multi_colors
                           when "single"
                             single_color
                           else
                             raise "highlight format '" + @text_color_style.to_s + "' not recognized"
                           end
        @file_name_color = make_color "reverse bold"
        @line_number_color = nil
      else
        @highlighter = nil
        @text_colors = Array.new
        @file_name_color = nil
        @line_number_color = nil
      end
    end

    def set_text_color index, color
      @text_colors[index] = color
    end

    def highlight_multi? str
      %w{ multi on true yes }.detect { |x| str == x }
    end

    def config_fields
      fields = {
        "file-color" => @file_name_color,
        "highlight" => @text_color_style,
        "line-number-color" => @line_number_color,
      }
    end

    def dump_fields
      fields = {
        "file_name_color" => colorize(@file_name_color, "filename"),
        "highlight" => @text_color_style,
        "line_number_color" => colorize(@line_number_color, "12345"),
      }
    end

    def colorize field, str
      if field
        field + str + Text::Color::RESET
      else
        str
      end
    end
    
    def update_fields fields
      fields.each do |name, values|
        case name
        when "file-color"
          @file_name_color = create_color name, values.last
        when "highlight"
          self.text_color_style = values.last
        when "line-number-color"
          @line_number_color = create_color name, values.last
        when "text-color"
          @text_colors = [ create_color(name, values.last) ]
        when %r{^text\-color\-(\d+)$}
          set_text_color $1.to_i, create_color(name, values.last)
        end
      end
    end
  end
end

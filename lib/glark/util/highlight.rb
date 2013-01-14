#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'rainbow'
require 'singleton'

module Highlight
  RESET = "\x1b[0m"
  
  def adorn hl, str
    hl + str + RESET
  end
end

module Sickill
  module Rainbow
    class AnsiColor
      $-w = false
      # includes the aberrant color name in the error message.
      def validate_color_name #:nodoc:
        color_names = TERM_COLORS.keys

        unless color_names.include?(@color)
          raise ArgumentError.new "Unknown color name: '#{@color}'; valid names: #{color_names.join(', ')}"
        end
      end
      $-w = true
    end
  end
end

class RainbowHighlighter
  include Singleton

  COLORS      = %w{ black red green yellow blue magenta cyan white [\dA-Fa-f]{6} }
  DECORATIONS = %w{ none reset bold underscore underline blink reverse inverse negative concealed }

  BACKGROUND_COLORS = COLORS.collect { |color| "on_#{color}" }
  FOREGROUND_COLORS = COLORS
  
  COLORS_RE = Regexp.new('(?: ' + 
                         # background will be in capture 0
                         'on(?:\s+|_) ( ' + COLORS.join(' | ') + ' ) | ' +
                         # foreground will be in capture 1
                         '( ' + (COLORS + DECORATIONS).join(' | ') + ' ) ' +
                         ')', Regexp::EXTENDED)

  def get_code color, type
    case color
    when 'bold', 'bright'
      Sickill::Rainbow::TERM_EFFECTS[:bright]
    when 'reverse', 'negative', 'inverse'
      Sickill::Rainbow::TERM_EFFECTS[:inverse]
    when 'underline'
      Sickill::Rainbow::TERM_EFFECTS[:underline]
    when 'blink'
      Sickill::Rainbow::TERM_EFFECTS[:blink]
    when %r{^[\dA-Fa-f]{6}$}
      ac = Sickill::Rainbow::AnsiColor.new type, color
      ac.code
    else
      ac = Sickill::Rainbow::AnsiColor.new type, color.to_sym
      ac.code
    end
  end

  def to_codes color
    codes = ""
    return codes unless Sickill::Rainbow.enabled
    color.scan(COLORS_RE).collect do |md|
      color, type = md[0] ? [ md[0], :background ] : [ md[1], :foreground ]
      code = get_code color, type
      "\e[#{code}m"
    end.join ''
  end
end

class HlWrapper
  def initialize
    @hl = RainbowHighlighter.instance
  end
  
  def make_color color
    @hl.to_codes color
  end
  
  def make_rgb_color red, green, blue, fgbg
    @hl.instance.to_rgb_code red, green, blue, fgbg
  end
end

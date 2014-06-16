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
      Rainbow::Presenter::TERM_EFFECTS[:bright]
    when 'reverse', 'negative', 'inverse'
      Rainbow::Presenter::TERM_EFFECTS[:inverse]
    when 'underline'
      Rainbow::Presenter::TERM_EFFECTS[:underline]
    when 'blink'
      Rainbow::Presenter::TERM_EFFECTS[:blink]
    when %r{^[\dA-Fa-f]{6}$}
      ac = Rainbow::Color.build type, [ color ]
      ac.codes.join(';')
    else
      ac = Rainbow::Color.build type, [ color.to_sym ]
      ac.codes.join(';')
    end
  end

  def to_codes color
    codes = ""
    return codes unless Rainbow.enabled
    color.scan(COLORS_RE).collect do |md|
      color, type = md[0] ? [ md[0], :background ] : [ md[1], :foreground ]
      code = get_code color, type
      "\e[#{code}m"
    end.join ''
  end
end

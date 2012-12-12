#!/usr/bin/ruby -w
# -*- ruby -*-

$rielold = false

require 'rubygems'
require 'riel'

if $rielold
  require 'riel/ansicolor'
else
  require 'riel/text/ansi/ansi_highlight'
end

module Highlight
  RESET = "\x1b[0m"
  
  def adorn hl, str
    if $rielold
      hl.highlight str
    else
      hl + str + RESET
    end
  end
end

class HlWrapper
  def initialize
    @hl = $rielold ? Text::ANSIHighlighter : Text::ANSIHighlighter
  end
  
  def make_color color
    if $rielold
      result = @hl.make color
    else
      @hl.instance.to_codes color
    end
  end
  
  def make_rgb_color color
    @hl.instance.to_codes color
  end
end

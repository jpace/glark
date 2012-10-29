#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module Glark; end

class Glark::LineStatus < Array
  WRITTEN = Object.new
  PRE_MATCH = '-'
  MATCH = ':'
  POST_MATCH = '+'

  def is_written? lnum
    self[lnum] == WRITTEN
  end

  def set_as_written lnum
    self[lnum] = WRITTEN
  end

  def char lnum
    self[lnum]
  end

  def set_status from, to, ch, force = false
    from.upto(to) do |ln|
      if self[ln].nil? || (force && self[ln] != WRITTEN)
        self[ln] = ch
      end
    end
  end

  def set_match pre_match_start, match_start, match_end, post_match_end
    start = [0, pre_match_start].max
    set_status start,         match_start - 1,    '-'
    set_status match_start,   match_end,          ':',  true
    set_status match_end + 1, post_match_end,     '+'
  end
end

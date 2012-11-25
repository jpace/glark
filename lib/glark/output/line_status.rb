#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module Glark; end

class Glark::LineStatus
  WRITTEN = Object.new
  PRE_MATCH = '-'
  MATCH = ':'
  POST_MATCH = '+'

  def initialize 
    @stati = Array.new
  end

  def is_written? lnum
    @stati[lnum] == WRITTEN
  end

  def set_as_written lnum
    @stati[lnum] = WRITTEN
  end

  def char lnum
    @stati[lnum]
  end

  def set_status from, to, status
    from.upto(to) do |lnum|
      update_status lnum, status
    end
  end

  def update_status lnum, status
    if @stati[lnum].nil? || (status == MATCH && @stati[lnum] != WRITTEN)
      @stati[lnum] = status
    end
  end

  def set_match pre_match_start, match_start, match_end, post_match_end
    start = [0, pre_match_start].max
    set_status start,         match_start - 1,    PRE_MATCH
    set_status match_start,   match_end,          MATCH
    set_status match_end + 1, post_match_end,     POST_MATCH
  end
end

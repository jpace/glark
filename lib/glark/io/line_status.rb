#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module Glark; end

class Glark::LineStatus < Array
  WRITTEN = Object.new

  def is_written? lnum
    self[lnum] == WRITTEN
  end

  def set_as_written lnum
    self[lnum] = WRITTEN
  end
end

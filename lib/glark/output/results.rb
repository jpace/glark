#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Results of searching files.

class Results
  include Loggable

  attr_reader :count

  def initialize
    @count = 0
  end

  def matched?
    @count > 0
  end

  def add_match
    @count += 1
  end
end

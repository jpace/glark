#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Distance for and expression

require 'rubygems'
require 'riel/regexp'
require 'glark/app/options'
require 'glark/match/re'
require 'glark/match/ior'
require 'glark/match/xor'
require 'glark/match/and'

class AndDistance
  include Loggable

  # signifies no limit to the distance between matches, i.e., anywhere within
  # the entire file is valid.
  INFINITE_DISTANCE = -1

  AND_EQ_NUM_RE = Regexp.new '^--and=(\-?\d+)?$'

  attr_reader :distance

  def initialize arg, args
    @distance = nil
    if arg == "-a"
      @distance = args.shift
    elsif arg == "--and"
      if args.size > 0 && numeric?(args[0])
        @distance = args.shift
      else
        @distance = "0"
      end
    elsif md = AND_EQ_NUM_RE.match(arg)
      @distance = md[1]
    else
      raise "invalid 'and' option: '#{arg}'"
    end

    # check to ensure that this is numeric
    if !numeric? @distance
      raise "invalid distance for 'and' expression: '#{@distance}'\n" +
        "    expecting an integer, or #{INFINITE_DISTANCE} for 'infinite'" 
    end
    
    if @distance.to_i == INFINITE_DISTANCE
      @distance = 1.0 / 0.0            # infinity
    else
      @distance = @distance.to_i
    end

    @distance
  end
  
  def numeric? x
    x && (x.kind_of?(Fixnum) || (x.to_i == INFINITE_DISTANCE || x.num))
  end  
end

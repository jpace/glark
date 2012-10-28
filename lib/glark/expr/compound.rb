#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/expr/expression'

# -------------------------------------------------------
# Compound expression function object
# -------------------------------------------------------

# Associates a collection of expressions.
class CompoundExpression < Expression
  attr_reader :ops

  def initialize(*ops)
    @ops  = ops
    @file = nil
    super()
  end

  def reset_file file
    @ops.each do |op|
      op.reset_file file
    end
    super
  end

  def start_position
    @last_start
  end
  
  def == other
    self.class == other.class && @ops == other.ops
  end  
end

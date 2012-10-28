#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/expr/or'

# Evaluates the expressions, and is satisfied if only one returns true.
class ExclusiveOrExpression < OrExpression
  def is_match? matched_ops
    return matched_ops.size == 1
  end

  def operator
    "xor"
  end

  def criteria
    "only one of"
  end
end

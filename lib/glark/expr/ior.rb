#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/expr/or'

# Evaluates the expressions, and is satisfied when one return true.
class InclusiveOrExpression < MultiOrExpression
  def is_match? matched_ops
    return matched_ops.size > 0
  end

  def operator
    "or"
  end

  def criteria
    ops.size == 2 ? "either" : "any of"
  end
end

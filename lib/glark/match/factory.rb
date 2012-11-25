#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Expression factory.

require 'rubygems'
require 'riel/regexp'
require 'glark/match/and'
require 'glark/match/and_distance'
require 'glark/match/ior'
require 'glark/match/re_factory'
require 'glark/match/xor'

class ExpressionFactory
  include Loggable

  attr_reader :expr

  def initialize matchspec
    @regexp_factory = RegexpExpressionFactory.new matchspec
  end

  # reads a file containing one regular expression per line.
  def read_file fname
    expr = nil
    File.open(fname) do |file|
      file.each_line do |line|
        line.strip!
        next if line.empty?

        # flatten the or expression instead of nesting it, to avoid
        # stack overruns for very large files.
        re = make_regular_expression line.chomp
        if expr 
          expr.ops << re
        else
          expr = InclusiveOrExpression.new re
        end
      end
    end
    expr
  end

  def make_regular_expression pattern, negated = false
    @regexp_factory.create_expression pattern, negated
  end

  # creates two expressions and returns them.
  def make_expressions args
    a1 = make_expression args
    a2 = make_expression args
    
    [ a1, a2 ]
  end

  # removes optional end tag
  def shift_end_tag name, args
    # explicit end tag is optional:
    args.shift if args[0] == ("--end-of-" + name)
  end
  
  def make_not_expression args
    expr = make_regular_expression args, true
    unless expr
      raise "'not' expression takes one argument"
    end

    # explicit end tag is optional:
    shift_end_tag "not", args
    expr
  end

  def make_two_expressions args, type
    a1, a2 = make_expressions args
    unless a1 && a2
      raise "'" + type + "' expression takes two arguments"
    end

    shift_end_tag type, args
    [ a1, a2 ]
  end

  def make_or_expression args
    a1, a2 = make_two_expressions args, "or"
    InclusiveOrExpression.new a1, a2
  end

  def make_xor_expression args
    a1, a2 = make_two_expressions args, "xor"
    ExclusiveOrExpression.new a1, a2
  end

  def make_and_distance arg, args
    adist = AndDistance.new arg, args
    adist.distance
  end
  
  def make_and_expression arg, args
    dist = make_and_distance arg, args

    a1, a2 = make_two_expressions args, "and"
    AndExpression.new dist, a1, a2
  end

  def make_infix_expression arg, args = []
    expr = nil

    while arg
      case arg
      when '('
        arg  = args.shift
        expr = make_infix_expression arg, args
      when '--or', '-o'
        arg  = args.shift
        rhs  = make_infix_expression arg, args
        expr = InclusiveOrExpression.new expr, rhs
      when '--xor'
        arg  = args.shift
        rhs  = make_infix_expression arg, args
        expr = ExclusiveOrExpression.new expr, rhs
      when Regexp.new('^--and'), '-a'
        dist = make_and_distance arg, args
        arg  = args.shift
        rhs  = make_infix_expression arg, args
        expr = AndExpression.new dist, expr, rhs
      when ')'
        break
      else
        expr = make_regular_expression arg
        break
      end
      arg = args.shift
    end

    if !expr
      raise "No expression provided."
    end

    expr
  end

  def make_expression args, warn_option = false
    arg = args[0]
    
    if arg
      case arg
      when "--or", "-o"
        args.shift
        make_or_expression args
      when "--xor"
        args.shift
        make_xor_expression args
      when %r{^\-\-and}, %r{^\-a}
        args.shift
        make_and_expression arg, args
      when '('
        args.shift
        make_infix_expression arg, args
      else
        if warn_option && arg.index(/^\-{1,2}\w/)
          raise "option not understood: #{arg}"
        end

        args.shift
        make_regular_expression arg
      end
    else
      nil
    end
  end
end

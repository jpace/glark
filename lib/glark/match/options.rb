#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for matching.

require 'rubygems'
require 'riel/log'
require 'glark/match/spec'
require 'glark/util/colors'
require 'glark/util/options'

class MatchOptions < Glark::MatchSpec
  include Glark::OptionUtil
  
  def initialize colors, optdata
    super colors    
    add_as_options optdata
  end

  def config_fields
    fields = {
      "ignore-case" => @ignorecase,
      "text-color" => text_highlights.join(' '),
    }
  end

  def dump_fields
    fields = {
      "expr" => @expr,
      "extract_matches" => @extract_matches,
      "ignorecase" => @ignorecase,
      "text_highlights" => text_highlights.compact.collect { |hl| hl.highlight("text") }.join(", "),
      "whole_lines" => @whole_lines,
      "whole_words" => @whole_words,
    }
  end

  def update_fields fields
    fields.each do |name, values|
      case name
      when "ignore-case"
        @ignorecase = to_boolean values.last
      end
    end
  end

  def add_as_options optdata
    add_opt_true optdata, :whole_words, %w{ -w --word }
    add_opt_true optdata, :ignorecase, %w{ -i --ignore-case }
    add_opt_true optdata, :whole_lines, %w{ -x --line-regexp }
    add_opt_true optdata, :extended, %w{ --extended }

    optdata << expr_file_option = {
      :tags => %w{ -f --file },
      :arg  => [ :string ],
      :set  => Proc.new { |fname| @expr = create_expression_factory.read_file fname }
    }

    add_opt_blk(optdata, %w{ -o -a }) do |md, opt, args|
      args.unshift opt
      @expr = create_expression_factory.make_expression args
    end

    optdata << text_color_option = {
      :tags => %w{ --text-color },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @colors.text_highlights = [ @colors.make_highlight("text-color", val) ] }
    }

    add_opt_true optdata, :extract_matches, %w{ -y --extract-matches }
  end
end

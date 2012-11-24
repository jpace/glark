#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/binary_file_summary'
require 'glark/output/context'
require 'glark/output/file_name_only'
require 'glark/output/glark_count'
require 'glark/output/glark_lines'
require 'glark/output/grep_count'
require 'glark/output/grep_lines'
require 'glark/output/unfiltered_lines'
require 'glark/util/options'

class OutputOptions < Glark::Options
  attr_accessor :context           # lines before and after
  attr_accessor :count             # only count the matches
  attr_accessor :file_names_only   # display only the file names
  attr_accessor :filter            # display only matches
  attr_accessor :invert_match      # display non-matching lines
  attr_accessor :label
  attr_accessor :match_limit       # the maximum number of matches to display per file
  attr_accessor :out
  attr_accessor :show_file_names   # display file names
  attr_accessor :show_line_numbers # display numbers of matching lines
  attr_accessor :write_null        # in @file_names_only mode, write '\0' instead of '\n'

  attr_reader :colors
  attr_reader :style            # grep, glark

  def initialize colors, optdata
    @colors = colors
    @context = Glark::Context.new
    @count = false
    @file_highlight = nil
    @file_names_only = false
    @filter = true
    @highlight = nil
    @invert_match = false
    @label = nil
    @match_limit = nil
    @out = $stdout
    @show_file_names = nil      # nil == > 1; true == >= 1; false means never
    @show_line_numbers = true
    @style = nil
    @write_null = false

    @output_cls = nil

    add_as_options optdata
  end

  def line_number_highlight
    @colors.line_number_highlight
  end

  def file_highlight 
    @colors.file_highlight
  end

  def highlight
    @colors.text_color_style
  end

  def after
    @context && @context.after
  end

  def before
    @context && @context.before
  end

  def style= style
    @style = style
    if @style == "glark"
      @colors.text_color_style = "multi"
    elsif @style == "grep"
      @colors.text_color_style = false
      @show_line_numbers = false
      @context.clear
    else
      raise "error: unrecognized style '" + style + "'"
    end
  end

  def config_fields
    fields = {
      "after-context" => @context.after,
      "before-context" => @context.before,
      "filter" => @filter,
      "output" => @style,
    }
  end

  def dump_fields
    fields = {
      "after" => @context.after,
      "before" => @context.before,
      "count" => @count,
      "file_names_only" => @file_names_only,
      "filter" => @filter,
      "invert_match" => @invert_match,
      "label" => @label,
      "match_limit" => @match_limit,
      "output" => @style,
      "show_file_names" => @show_file_names,
      "show_line_numbers" => @show_line_numbers,
      "write_null" => @write_null
    }
  end

  def update_fields fields
    fields.each do |name, values|
      case name
      when "grep"
        self.style = "grep" if to_boolean values.last
      when "output"
        self.style = values.last
      end
    end
    @context.update_fields fields
  end

  def create_output_type file
    output_type_cls.new file, self
  end

  def output_type_cls
    if @output_cls
      return @output_cls
    end
    
    @output_cls = if @count
                    if @style == "grep" 
                      GrepCount
                    else
                      GlarkCount
                    end
                  elsif @file_names_only
                    FileNameOnly
                  elsif !@filter
                    UnfilteredLines
                  elsif @style == "grep"
                    GrepLines
                  else
                    GlarkLines
                  end
  end

  def set_file_names_only invert_match
    @file_names_only = true
    @invert_match = invert_match
  end

  def add_as_options optdata
    @context.add_as_option optdata

    add_opt_true optdata, :invert_match, %w{ -v --invert-match }

    add_opt_true optdata, :filter, %w{ --filter }
    add_opt_false optdata, :filter, %w{ --no-filter --nofilter }
    
    add_opt_true optdata, :show_line_numbers, %w{ -n --line-number }
    add_opt_false optdata, :show_line_numbers, %w{ -N --no-line-number }

    add_opt_blk(optdata, %w{ -l --files-with-matches }) { set_file_names_only false }
    add_opt_blk(optdata, %w{ -L --files-without-match }) { set_file_names_only true }
    
    add_opt_true optdata, :write_null, %w{ -Z --null }

    add_opt_str optdata, :label, %w{ --label }
    
    add_opt_int optdata, :match_limit, %w{ -m --match-limit }

    add_opt_blk(optdata, %w{ -U --no-highlight }) { @colors.text_color_style =  nil }
    add_opt_blk(optdata, %w{ -g --grep }) { self.style = "grep" }
    
    optdata << lnum_color_option = {
      :tags => %w{ --line-number-color },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @colors.line_number_highlight = @colors.make_highlight "line-number-color", val },
    }

    add_opt_true optdata, :count, %w{ -c --count }

    add_opt_true optdata, :show_file_names, %w{ -H --with-filename }
    add_opt_false optdata, :show_file_names, %w{ -h --no-filename }

    optdata << highlight_option = { 
      :tags => %w{ -u --highlight },
      :arg  => [ :optional, :regexp, %r{ ^ (?:(multi|single)|none) $ }x ],
      :set  => Proc.new { |md| val = md ? md[1] : "multi"; @colors.text_color_style =  val }
    }

    optdata << file_color_option = {
      :tags => %w{ --file-color },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @colors.file_highlight = @colors.make_highlight "file-color", val }
    }
  end
end

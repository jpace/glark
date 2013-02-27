#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/output/spec'
require 'glark/util/options'

module Glark
  class OutputOptions < OutputSpec
    include OptionUtil
    
    def initialize colors, optdata
      super colors

      add_as_options optdata
    end

    def config_fields
      {
        "after-context" => @context.after,
        "before-context" => @context.before,
        "filter" => @filter,
        "output" => @style,
      }
    end

    def dump_fields
      {
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
      
      optdata << {
        :tags => %w{ --line-number-color },
        :arg  => [ :string ],
        :set  => Proc.new { |val| @colors.line_number_color = @colors.create_color "line-number-color", val },
      }

      add_opt_true optdata, :count, %w{ -c --count }

      add_opt_true optdata, :show_file_names, %w{ -H --with-filename }
      add_opt_false optdata, :show_file_names, %w{ -h --no-filename }

      optdata << { 
        :tags => %w{ -u --highlight },
        :arg  => [ :optional, :regexp, %r{ ^ (?:(multi|single)|none) $ }x ],
        :set  => Proc.new { |md| val = md ? md[1] : "multi"; @colors.text_color_style = val }
      }

      optdata << {
        :tags => %w{ --file-color },
        :arg  => [ :string ],
        :set  => Proc.new { |val| @colors.file_name_color = @colors.create_color "file-color", val }
      }
    end
  end
end

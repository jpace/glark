#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

class OutputOptions
  attr_accessor :context
  attr_accessor :file_highlight
  attr_accessor :file_names_only
  attr_accessor :filter
  attr_accessor :highlight
  attr_accessor :invert_match
  attr_accessor :label
  attr_accessor :line_number_highlight
  attr_accessor :match_limit
  attr_accessor :out
  attr_accessor :show_file_names
  attr_accessor :show_line_numbers
  attr_accessor :write_null

  def initialize 
    @context = Glark::Context.new
    @file_highlight = nil
    @file_names_only = nil
    @filter = filter
    @highlight = nil
    @invert_match = nil
    @label = nil
    @line_number_highlight = nil
    @match_limit = nil
    @out = nil
    @show_file_names = nil
    @show_line_numbers = nil
    @write_null = nil
  end

  def after
    @context && @context.after
  end

  def before
    @context && @context.before
  end

  def add_as_options optdata
    @context.add_as_option optdata

    optdata << invert_match_option = {
      :tags => %w{ -v --invert-match },
      :set  => Proc.new { @invert_match = true }
    }

    optdata << filter_option = {
      :tags => %w{ --filter },
      :set  => Proc.new { @filter = true }
    }

    optdata << nofilter_option = {
      :tags => %w{ --no-filter --nofilter },
      :set  => Proc.new { @filter = false }
    }

    optdata << show_lnums_option = {
      :tags => %w{ -n --line-number },
      :set  => Proc.new { @show_line_numbers = true }
    }

    optdata << no_show_lnums_option = {
      :tags => %w{ -N --no-line-number },
      :set  => Proc.new { @show_line_numbers = false }
    }

    optdata << matching_fnames_option = {
      :tags => %w{ -l --files-with-matches },
      :set  => Proc.new { @file_names_only = true; @invert_match = false }
    }

    optdata << nonmatching_fnames_option = {
      :tags => %w{ -L --files-without-match },
      :set  => Proc.new { @file_names_only = true; @invert_match = true }
    }

    optdata << write_null_option = {
      :tags => %w{ -Z --null },
      :set  => Proc.new { @write_null = true }
    }

    optdata << label_option = { 
      :tags => %w{ --label },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @label = val }
    }

    optdata << match_limit_option = { 
      :tags => %w{ -m --match-limit },
      :arg  => [ :integer ],
      :set  => Proc.new { |val| @match_limit = val }
    }
  end
end

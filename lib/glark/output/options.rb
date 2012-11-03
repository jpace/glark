#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

class OutputOptions

  attr_accessor :context         # lines before and after
  attr_accessor :file_names_only # display only the file names
  attr_accessor :filter          # display only matches
  attr_accessor :invert_match    # display non-matching lines
  attr_accessor :label
  attr_accessor :match_limit # the maximum number of matches to display per file
  attr_accessor :out
  attr_accessor :show_file_names   # display file names
  attr_accessor :show_line_numbers # display numbers of matching lines
  attr_accessor :write_null # in @file_names_only mode, write '\0' instead of '\n'

  attr_reader :colors
  attr_reader :style            # grep, glark

  def initialize colors
    @colors = colors
    @context = Glark::Context.new
    @file_highlight = nil
    @file_names_only = false
    @filter = true
    @highlight = nil
    @invert_match = false
    @label = nil
    @match_limit = nil
    @out = $stdout
    @show_file_names = nil
    @show_line_numbers = true
    @style = nil
    @write_null = false
  end

  def set_files files
    if @show_file_names.nil?
      @show_file_names = files.size > 1 || @label || (files.size == 1 && directory?(files[0]))
    end
  end

  def directory? file
    file != "-" && FileType.type(file) == FileType::DIRECTORY
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

#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

class OutputOptions
  include Loggable
  
  attr_accessor :context         # lines before and after
  attr_accessor :count           # only count the matches
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

    optdata << nohighlight_option = {
      :tags => %w{ -U --no-highlight },
      :set  => Proc.new { @colors.text_color_style =  nil }
    }

    optdata << grep_output_option = {
      :tags => %w{ -g --grep },
      :set  => Proc.new { self.style = "grep" }
    }

    optdata << lnum_color_option = {
      :tags => %w{ --line-number-color },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @colors.line_number_highlight = @colors.make_highlight "line-number-color", val },
    }

    optdata << count_option = {
      :tags => %w{ -c --count },
      :set  => Proc.new { @count = true }
    }
    
    optdata << show_fname_option = {
      :tags => %w{ -H --with-filename },
      :set  => Proc.new { @show_file_names = true }
    }

    optdata << no_show_fname_option = {
      :tags => %w{ -h --no-filename },
      :set  => Proc.new { @show_file_names = false }
    }

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

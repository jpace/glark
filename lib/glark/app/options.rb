#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/app/rcfile'
require 'glark/match/factory'
require 'glark/match/options'
require 'glark/input/range'
require 'glark/output/options'
require 'glark/output/context'

module Glark
  PACKAGE = 'glark'
  VERSION = '1.9.1'
end

class Glark::Colors
  include Loggable
  
  attr_accessor :highlighter

  def initialize hl = nil
    @highlighter = nil
  end

  # creates a color for the given option, based on its value
  def make_highlight opt, value
    if @highlighter
      if value
        @highlighter.make value
      else
        raise "error: '" + opt + "' requires a color"
      end
    else
      log { "no highlighter defined" }
    end
  end

  def make_colors limit = -1
    Text::Highlighter::DEFAULT_COLORS[0 .. limit].collect { |color| @highlighter.make color }
  end

  def multi_colors 
    make_colors
  end

  def single_color
    make_colors 0
  end
end

# -------------------------------------------------------
# Options
# -------------------------------------------------------

class Glark::Options
  include Loggable

  attr_accessor :binary_files
  attr_accessor :directory
  attr_accessor :exclude_matching
  attr_accessor :explain
  attr_accessor :extract_matches
  attr_accessor :file_highlight
  attr_accessor :highlight
  attr_accessor :line_number_highlight
  attr_accessor :local_config_files
  attr_accessor :output
  attr_accessor :quiet
  attr_accessor :show_break
  attr_accessor :show_file_names
  attr_accessor :size_limit
  attr_accessor :split_as_path
  attr_accessor :verbose
  attr_accessor :with_basename
  attr_accessor :with_fullname
  attr_accessor :without_basename
  attr_accessor :without_fullname

  attr_reader :count
  attr_reader :invert_match
  attr_reader :range

  def expr
    @matchopts.expr
  end

  def filter
    @outputopts.filter
  end

  def file_names_only
    @outputopts.file_names_only
  end

  def out= io
    @outputopts.out = io
  end
  
  def initialize
    optdata = Array.new

    add_input_options optdata
    add_match_options optdata
    add_output_options optdata
    add_info_options optdata
    
    @optset = OptProc::OptionSet.new optdata
    
    @binary_files          = "binary"   # 
    @count                 = false      # just count the lines
    @directory             = "read"     # read, skip, or recurse, a la grep
    @exclude_matching      = false      # exclude files whose names match the expression
    @explain               = false      # display a legible version of the expression
    @extract_matches       = false      # whether to show _only_ the part that matched
    @highlight             = "multi"    # highlight matches (using ANSI codes)
    @local_config_files    = false      # use local .glarkrc files

    @quiet                 = false      # minimize warnings
    @range.clear              # range to search; nil => the entire file
    @show_file_names       = nil        # show the names of matching files; nil == > 1; true == >= 1; false means never
    @split_as_path         = true       # whether to split arguments that include the path separator
    @verbose               = nil        # display debugging output
    @with_basename         = nil        # match files with this basename
    @with_fullname         = nil        # match files with this fullname
    @without_basename      = nil        # match files without this basename
    @without_fullname      = nil        # match files without this fullname
    
    clear_colors

    @outputopts.label = nil
    @size_limit            = nil

    $/ = "\n"

    @colors = Glark::Colors.new
    @highlighter = nil
    
    set_glark_output_style
  end

  def add_input_options optdata
    optdata << record_separator_option = {
      :res => [ Regexp.new '^ -0 (\d{1,3})? $ ', Regexp::EXTENDED ],
      :set => Proc.new { |md| rs = md ? md[1] : 0; set_record_separator rs }
    }

    @range = Glark::Range.new # range to start and stop searching; nil => the entire file
    @range.add_as_option optdata
    
    optdata << exclude_matching_option = {
      :tags => %w{ -M --exclude-matching },
      :set  => Proc.new { @exclude_matching = true }
    }

    optdata << exclude_matching_option = {
      :tags => %w{ -d },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @directory = val }
    }

    optdata << exclude_matching_option = {
      :tags => %w{ -r --recurse },
      :set  => Proc.new { @directory = "recurse" }
    }

    optdata << extract_matches_option = {
      :tags => %w{ -y --extract-matches },
      :set  => Proc.new { @extract_matches = true }
    }

    optdata << no_split_as_path_option = {
      :tags => %w{ --no-split-as-path },
      :set  => Proc.new { @split_as_path = false }
    }

    optdata << split_as_path_option = {
      :tags => %w{ --split-as-path },
      :arg  => [ :boolean, :optional ],
      :set  => Proc.new { |val| @split_as_path = val }
    }

    optdata << dir_option = {
      :tags => %w{ --directories },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @directory = val }
    }

    optdata << basename_option = {
      :tags => %w{ --basename --name --with-basename --with-name },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @with_basename = Regexp.create pat }
    }

    optdata << without_basename_option = {
      :tags => %w{ --without-basename --without-name },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @without_basename = Regexp.create pat }
    }

    optdata << fullname_option = {
      :tags => %w{ --fullname --path --with-fullname --with-path },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @with_fullname = Regexp.create pat }
    }

    optdata << without_fullname_option = {
      :tags => %w{ --without-fullname --without-path },
      :arg  => [ :string ],
      :set  => Proc.new { |pat| @without_fullname = Regexp.create pat }
    }

    optdata << binary_files_option = {
      :tags    => %w{ --binary-files },
      :arg     => [ :required, :regexp, %r{ ^ [\'\"]? (text|without\-match|binary) [\'\"]? $ }x ],
      :set     => Proc.new { |md| @binary_files = md[1] },
      :rc   => %w{ binary-files },
    }

    optdata << size_limit_option = {
      :tags => %w{ --size-limit },
      :arg  => [ :integer ],
      :set  => Proc.new { |val| @size_limit = val }
    }
  end
  
  def add_match_options optdata
    @matchopts = MatchOptions.new
    
    @matchopts.add_as_options optdata

    optdata << text_color_option = {
      :tags => %w{ --text-color },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @matchopts.text_highlights = [ make_highlight "text-color", val ] }
    }
  end

  def add_output_options optdata
    @outputopts = OutputOptions.new

    @outputopts.add_as_options optdata
    
    optdata << nohighlight_option = {
      :tags => %w{ -U --no-highlight },
      :set  => Proc.new { set_highlight nil }
    }

    optdata << grep_output_option = {
      :tags => %w{ -g --grep },
      :set  => Proc.new { set_grep_output_style }
    }

    optdata << lnum_color_option = {
      :tags => %w{ --line-number-color },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @line_number_highlight = make_highlight "line-number-color", val },
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
      :set  => Proc.new { |md| val = md ? md[1] : "multi"; set_highlight val }
    }

    optdata << file_color_option = {
      :tags => %w{ --file-color },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @file_highlight = make_highlight "file-color", val }
    }
  end

  def add_info_options optdata
    optdata << version_option = {
      :tags => %w{ -V --version },
      :set  => Proc.new { show_version }
    }

    optdata << verbose_option = {
      :tags => %w{ --verbose },
      :set  => Proc.new { |val| Log.verbose = true }
    }
    
    optdata << help_option = {
      :tags => %w{ -? --help },
      :set  => Proc.new { require 'glark/app/help';  GlarkHelp.new.show_usage; exit 0 }
    }

    optdata << man_option = {
      :tags => %w{ --man },
      :set  => Proc.new { require 'glark/app/help';  GlarkHelp.new.show_man; exit 0 }
    }
    
    optdata << explain_option = {
      :tags => %w{ --explain },
      :set  => Proc.new { @explain = true }
    }

    optdata << quiet_option = {
      :tags => %w{ -q -s --quiet --messages },
      :set  => Proc.new { Log.quiet = @quiet = true }
    }

    optdata << noquiet_option = {
      :tags => %w{ -Q -S --no-quiet --no-messages },
      :set  => Proc.new { Log.quiet = @quiet = false }
    }

    optdata << config_option = {
      :tags => %w{ --conf },
      :set  => Proc.new { write_configuration; exit }
    }

    optdata << dump_option = {
      :tags => %w{ --dump },
      :set  => Proc.new { dump_all_fields; exit 0 }
    }
  end
  
  def highlighter
    @colors.highlighter 
  end

  def highlighter= hl
    @colors.highlighter = hl
  end

  def make_colors limit = -1
    Text::Highlighter::DEFAULT_COLORS[0 .. limit].collect { |color| highlighter.make color }
  end

  def multi_colors 
    make_colors
  end

  def single_color
    make_colors 0
  end

  def highlight_multi? str
    %w{ multi on true yes }.detect { |x| str == x }
  end

  def reset_colors
    if !@highlight || !highlighter
      clear_colors
    else
      set_colors
    end
  end

  def set_colors
    @matchopts.text_highlights = case @highlight
                                 when highlight_multi?(@highlight), true
                                   @colors.multi_colors
                                 when "single"
                                   @colors.single_color
                                 else
                                   raise "highlight format '" + @highlight.to_s + "' not recognized"
                                 end
    @file_highlight        = highlighter.make "reverse bold"
    @line_number_highlight = nil
  end

  def clear_colors
    @matchopts.text_highlights = Array.new
    @file_highlight        = nil
    @line_number_highlight = nil
  end

  def set_highlight type
    @highlight = type
    @matchopts.highlight = @highlight
    self.highlighter = @highlight && Text::ANSIHighlighter
    reset_colors
  end

  def set_glark_output_style
    @output = "glark"
    set_highlight @highlight
  end

  def set_grep_output_style
    @output = "grep"
    set_highlight false

    @colors.highlighter = nil
    @outputopts.show_line_numbers = false
    @outputopts.context.after = 0
    @outputopts.context.before = 0
  end

  def set_output_style output
    @output = output

    case @output
    when "ansi", "xterm", "glark"
      set_glark_output_style
    when "grep"
      set_grep_output_style
    end
  end

  def run args
    @args = args

    read_home_rcfiles

    if @local_config_files
      read_local_rcfiles
    end

    read_environment_variable

    # honor thy EMACS; go to grep mode
    if ENV["EMACS"]
      set_grep_output_style
    end

    read_options

    validate
  end

  def read_home_rcfiles
    if hdir = Env.home_directory
      hdpn = Pathname.new hdir
      homerc = hdpn + ".glarkrc"
      read_rcfile homerc
    end
  end

  def read_local_rcfiles
    hdir = Env.home_directory
    dir = Pathname.new(".").expand_path
    while !dir.root? && dir != hdir
      rcfile = dir + ".glarkrc"
      if rcfile.exist?
        read_rcfile rcfile
        return
      else
        dir = dir.dirname
      end
    end
  end

  def set_record_separator sep
    log { "sep: #{sep}" }
    $/ = if sep && sep.to_i > 0
           begin
             sep.oct.chr
           rescue RangeError => e
             # out of range (e.g., 777) means nil:
             nil
           end
         else
           log { "setting to paragraph" }
           "\n\n"
         end
    
    log { "record separator set to #{$/.inspect}" }
  end

  def read_rcfile rcfname
    rcfile = Glark::RCFile.new rcfname
    
    rcfile.names.each do |name|
      value = rcfile.value name
      
      case name
      when "file-color"
        @file_highlight = make_highlight name, value
      when "grep"
        set_grep_output_style if to_boolean value
      when "highlight"
        @highlight = value
        @matchopts.highlight = value
      when "ignore-case"
        @matchopts.ignorecase = to_boolean value
      when "known-nontext-files"
        value.split.each do |ext|
          FileTester.set_nontext ext
        end
      when "known-text-files"
        value.split.each do |ext|
          FileTester.set_text ext
        end
      when "local-config-files"
        @local_config_files = to_boolean value
      when "line-number-color"
        @line_number_highlight = make_highlight name, value
      when "output"
        set_output_style value
      when "quiet"
        Log.quiet = @quiet = to_boolean(value)
      when "text-color"
        @matchopts.text_highlights = [ make_highlight name, value ]
      when %r{^text\-color\-(\d+)$}
        @matchopts.text_highlights[$1.to_i] = make_highlight name, value
      when "verbose"
        Log.verbose = @verbose = to_boolean(value) ? 1 : nil
      when "verbosity"
        Log.verbose = @verbose = value.to_i
      when "split-as-path"
        @split_as_path = to_boolean value
      when "size-limit"
        @size_limit = value.to_i
      end
    end
  end
  
  # creates a color for the given option, based on its value
  def make_highlight opt, value
    @colors.make_highlight opt, value
  end

  # returns whether the value matches a true value, such as "yes", "true", or "on".
  def to_boolean value
    [ "yes", "true", "on" ].include? value.downcase
  end

  def read_environment_variable
    options = Env.split "GLARKOPTS"
    while options.size > 0
      @optset.process_option options
    end
  end

  def read_expression
    if @args.size > 0
      known_end = false
      if @args[0] == "--"
        log { "end of options" }
        @args.shift
        known_end = true
      end
      
      if @args && @args.size > 0
        @matchopts.expr = get_expression_factory.make_expression @args, !known_end
        return
      end
    end
    
    if @args.size > 0
      error "No expression provided."
    end
    
    $stderr.puts "Usage: glark [options] expression file..."
    $stderr.puts "Try `glark --help' for more information."
    exit 1
  end

  def read_options
    # solitary "-v" means "--version", not --invert-match
    show_version if @args.size == 1 && @args[0] == "-v"
    
    @matchopts.expr = nil
    
    nil while @args.size > 0 && @optset.process_option(@args)

    unless @matchopts.expr
      read_expression
    end
  end

  def write_configuration
    fields = {
      "after-context" => @outputopts.context.after,
      "before-context" => @outputopts.context.before,
      "binary-files" => @binary_files,
      "file-color" => @file_highlight,
      "filter" => @outputopts.filter,
      "highlight" => @highlight,
      "ignore-case" => @matchopts.ignorecase,
      "known-nontext-files" => FileTester.nontext_extensions.sort.join(' '),
      "known-text-files" => FileTester.text_extensions.sort.join(' '),
      "line-number-color" => @line_number_highlight,
      "local-config-files" => @local_config_files,
      "output" => @output,
      "quiet" => @quiet,
      "size-limit" => @size_limit,
      "split-as-path" => @split_as_path,
      "text-color" => @matchopts.text_highlights.join(' '),
      "verbose" => @verbose,
    }
    
    fields.keys.sort.each do |fname|
      puts  
      puts "#{fname}: #{fields[fname]}"
    end
  end

  def dump_all_fields
    fields = {
      "after" => @outputopts.context.after,
      "before" => @outputopts.context.before,
      "binary_files" => @binary_files,
      "count" => @count,
      "directory" => @directory,
      "exclude_matching" => @exclude_matching,
      "explain" => @explain,
      "expr" => @matchopts.expr,
      "extract_matches" => @extract_matches,
      "file_highlight" => @file_highlight ? @file_highlight.highlight("filename") : "filename",
      "file_names_only" => @outputopts.file_names_only,
      "filter" => @outputopts.filter,
      "highlight" => @highlight,
      "ignorecase" => @matchopts.ignorecase,
      "invert_match" => @outputopts.invert_match,
      "known_nontext_files" => FileTester.nontext_extensions.join(", "),
      "known_text_files" => FileTester.text_extensions.join(", "),
      "label" => @outputopts.label,
      "line_number_highlight" => @line_number_highlight ? @line_number_highlight.highlight("12345") : "12345",
      "local_config_files" => @local_config_files,
      "match_limit" => @outputopts.match_limit,
      "output" => @output,
      "quiet" => @quiet,
      "ruby version" => RUBY_VERSION,
      "show_file_names" => @show_file_names,
      "show_line_numbers" => @outputopts.show_line_numbers,
      "text_highlights" => @matchopts.text_highlights.compact.collect { |hl| hl.highlight("text") }.join(", "),
      "verbose" => @verbose,
      "version" => Glark::VERSION,
      "whole_lines" => @matchopts.whole_lines,
      "whole_words" => @matchopts.whole_words,
      "with-basename" => @with_basename,
      "with-fullname" => @with_fullname,
      "without-basename" => @without_basename,
      "without-fullname" => @without_fullname,
      "write_null" => @outputopts.write_null,
    }

    len = fields.keys.collect { |f| f.length }.max
    
    fields.keys.sort.each do |field|
      printf "%*s : %s\n", len, field, fields[field]
    end
  end

  def get_match_options
    @matchopts
  end

  # check options for collisions/data validity
  def validate
    range = @range
    return true if range.nil?
    
    begin
      range.valid?
    rescue Glark::RangeError => e
      $stderr.puts e
      exit 2
    end
  end

  def get_expression_factory
    # we'll be creating this each time, in case these options change
    ExpressionFactory.new get_match_options
  end

  def show_version
    puts Glark::PACKAGE + ", version " + Glark::VERSION
    puts "Written by Jeff Pace (jeugenepace@gmail.com)."
    puts "Released under the Lesser GNU Public License."
    exit 0
  end

  def display_file_names? files
    return true  if @show_file_names
    return false if !@show_file_names.nil?
    return true  if @outputopts.label
    return false if files.size == 0
    return true  if files.size > 1
    files[0] != "-" && FileType.type(files[0]) == FileType::DIRECTORY
  end

  def get_output_options files
    @outputopts.file_highlight = @file_highlight
    @outputopts.highlight = @highlight
    @outputopts.line_number_highlight = @line_number_highlight
    @outputopts.show_file_names = display_file_names? files

    @outputopts
  end
end

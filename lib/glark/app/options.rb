#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/expr/exprfactory'
require 'glark/io/range'

module Glark
  PACKAGE = 'glark'
  VERSION = '1.9.1'
end

# -------------------------------------------------------
# Options
# -------------------------------------------------------

class Glark::RangeOption
  attr_accessor :range
  
  def initialize 
    @range = nil
  end

  def options
    range_after_option = {
      :tags    => %w{ --after },
      :arg     => [ :required, :regexp, %r{ (\d+%?) $ }x ],
      :set     => Proc.new { |md| (@range ||= Glark::Range.new).from = md[1] }
    }

    range_before_option = { 
      :tags    => %w{ --before },
      :arg     => [ :required, :regexp, %r{ (\d+%?) $ }x ],
      :set     => Proc.new { |md| (@range ||= Glark::Range.new).to = md[1] }
    }

    range_option = {
      :tags     => %w{ -R --range },
      :arg      => [ :required, :regexp, Regexp.new('(\d+%?),(\d+%?)') ],
      :set      => Proc.new do |md, opt, args|
        @range = if md && md[1] && md[2]
                   Glark::Range.new md[1], md[2]
                 else
                   Glark::Range.new args.shift, args.shift
                 end
      end
    }

    [ range_after_option, range_before_option, range_option ]
  end
end


class Glark::Options
  include Loggable, Singleton

  attr_accessor :after
  attr_accessor :before
  attr_accessor :binary_files
  attr_accessor :count
  attr_accessor :directory
  attr_accessor :exclude_matching
  attr_accessor :explain
  attr_accessor :expr
  attr_accessor :extended
  attr_accessor :extract_matches
  attr_accessor :file_highlight
  attr_accessor :file_names_only
  attr_accessor :filter
  attr_accessor :highlight
  attr_accessor :highlighter
  attr_accessor :invert_match
  attr_accessor :label
  attr_accessor :line_number_highlight
  attr_accessor :local_config_files
  attr_accessor :match_limit
  attr_accessor :multiline
  attr_accessor :nocase
  attr_accessor :out
  attr_accessor :output
  attr_accessor :quiet
  attr_accessor :show_break
  attr_accessor :show_file_names
  attr_accessor :show_line_numbers
  attr_accessor :size_limit
  attr_accessor :split_as_path
  attr_accessor :text_highlights
  attr_accessor :verbose
  attr_accessor :version
  attr_accessor :whole_lines
  attr_accessor :whole_words
  attr_accessor :with_basename
  attr_accessor :with_fullname
  attr_accessor :without_basename
  attr_accessor :without_fullname
  attr_accessor :write_null

  def initialize
    @range_option = Glark::RangeOption.new
    rg_options = @range_option.options

    range_after_option, range_before_option, range_option = *rg_options
    
    context_option = {
      :tags => %w{ -C --context },
      :res  => %r{ ^ - ([1-9]\d*) $ }x,
      :arg  => [ :optional, :integer ],
      :set  => Proc.new { |val, opt, args| @after = @before = val || 2 },
      :rc   => %w{ context },
    }

    context_after_option = {
      :tags => %w{ --after-context -A },
      :arg  => [ :integer ],
      :set  => Proc.new { |val| @after = val },
      :rc   => %w{ after-context },
    }

    context_before_option = {
      :tags => %w{ --before-context -B },
      :arg  => [ :integer ],
      :set  => Proc.new { |val| @before = val },
      :rc   => %w{ before-context },
    }
    
    optdata = [ 
               context_option,
               context_after_option,
               context_before_option,
               {
                 :tags => %w{ -V --version },
                 :set  => Proc.new { show_version }
               },
               {
                 :tags => %w{ --verbose --verbosity },
                 :set  => Proc.new { |val| Log.verbose = true }
               },
               {
                 :tags => %w{ -v --invert-match },
                 :set  => Proc.new { @invert_match = true }
               },
               {
                 :tags => %w{ -i --ignore-case },
                 :set  => Proc.new { @nocase = true }
               },
               {
                 :tags => %w{ --filter },
                 :set  => Proc.new { @filter = true }
               },
               {
                 :tags => %w{ --no-filter --nofilter },
                 :set  => Proc.new { @filter = false }
               },
               {
                 :tags => %w{ -U --no-highlight },
                 :set  => Proc.new { set_highlight nil }
               },
               {
                 :tags => %w{ -g --grep },
                 :set  => Proc.new { set_output_style "grep" }
               },
               {
                 :tags => %w{ -? --help },
                 :set  => Proc.new { require 'glark/app/help';  GlarkHelp.new.show_usage; exit 0 }
               },
               {
                 :tags => %w{ --man },
                 :set  => Proc.new { require 'glark/app/help';  GlarkHelp.new.show_man; exit 0 }
               },
               {
                 :tags => %w{ --explain },
                 :set  => Proc.new { @explain = true }
               },
               {
                 :tags => %w{ -n --line-number },
                 :set  => Proc.new { @show_line_numbers = true }
               },
               {
                 :tags => %w{ -N --no-line-number },
                 :set  => Proc.new { @show_line_numbers = false }
               },
               {
                 :tags => %w{ --line-number-color },
                 :arg  => [ :string ],
                 :set  => Proc.new { |val| @line_number_highlight = make_highlight "line-number-color", val },
               },
               {
                 :tags => %w{ -q -s --quiet --messages },
                 :set  => Proc.new { Log.quiet = @quiet = true }
               },
               {
                 :tags => %w{ -Q -S --no-quiet --no-messages },
                 :set  => Proc.new { Log.quiet = @quiet = false }
               },
               {
                 :tags => %w{ -w --word --word-regexp },
                 :set  => Proc.new { @whole_words = true }
               },
               {
                 :tags => %w{ -x --line-regexp },
                 :set  => Proc.new { @whole_lines = true }
               },
               {
                 :tags => %w{ -l --files-with-matches },
                 :set  => Proc.new { @file_names_only = true; @invert_match = false }
               },
               {
                 :tags => %w{ -L --files-without-match },
                 :set  => Proc.new { @file_names_only = true; @invert_match = true }
               },
               {
                 :tags => %w{ --extended },
                 :set  => Proc.new { @extended = true }
               },
               {
                 :tags => %w{ --multiline },
                 :set  => Proc.new { @multiline = true }
               },
               {
                 :tags => %w{ -c --count },
                 :set  => Proc.new { @count = true }
               },
               {
                 :tags => %w{ -Z --null },
                 :set  => Proc.new { @write_null = true }
               },
               {
                 :tags => %w{ -M --exclude-matching },
                 :set  => Proc.new { @exclude_matching = true }
               },
               {
                 :tags => %w{ -d },
                 :arg  => [ :string ],
                 :set  => Proc.new { |val| @directory = val }
               },
               {
                 :tags => %w{ -r --recurse },
                 :set  => Proc.new { @directory = "recurse" }
               },
               {
                 :tags => %w{ -y --extract-matches },
                 :set  => Proc.new { @extract_matches = true }
               },
               {
                 :tags => %w{ --conf },
                 :set  => Proc.new { write_configuration; exit }
               },
               {
                 :tags => %w{ --dump },
                 :set  => Proc.new { dump_all_fields; exit 0 }
               },
               {
                 :tags => %w{ --no-split-as-path },
                 :set  => Proc.new { @split_as_path = false }
               },
               {
                 :tags => %w{ --split-as-path },
                 :arg  => [ :boolean, :optional ],
                 :set  => Proc.new { |val| @split_as_path = val }
               },
               {
                 :tags => %w{ --directories },
                 :arg  => [ :string ],
                 :set  => Proc.new { |val| @directory = val }
               },
               {
                 :tags => %w{ -H --with-filename },
                 :set  => Proc.new { @show_file_names = true }
               },
               {
                 :tags => %w{ -h --no-filename },
                 :set  => Proc.new { @show_file_names = false }
               },
               { 
                 :tags => %w{ --label },
                 :arg  => [ :string ],
                 :set  => Proc.new { |val| @label = val }
               },
               { 
                 :tags => %w{ -m --match-limit },
                 :arg  => [ :integer ],
                 :set  => Proc.new { |val| @match_limit = val }
               },
               { 
                 :tags => %w{ -u --highlight },
                 :arg  => [ :optional, :regexp, %r{ ^ (?:(multi|single)|none) $ }x ],
                 :set  => Proc.new { |md| val = md ? md[1] : "multi"; set_highlight val }
               },
               { 
                 :tags => %w{ --basename --name --with-basename --with-name },
                 :arg  => [ :string ],
                 :set  => Proc.new { |pat| @with_basename = Regexp.create pat }
               },
               { 
                 :tags => %w{ --without-basename --without-name },
                 :arg  => [ :string ],
                 :set  => Proc.new { |pat| @without_basename = Regexp.create pat }
               },
               { 
                 :tags => %w{ --fullname --path --with-fullname --with-path },
                 :arg  => [ :string ],
                 :set  => Proc.new { |pat| @with_fullname = Regexp.create pat }
               },
               { 
                 :tags => %w{ --without-fullname --without-path },
                 :arg  => [ :string ],
                 :set  => Proc.new { |pat| @without_fullname = Regexp.create pat }
               },
               range_after_option,
               range_before_option,
               range_option,
               {
                 :tags    => %w{ --binary-files },
                 :arg     => [ :required, :regexp, %r{ ^ [\'\"]? (text|without\-match|binary) [\'\"]? $ }x ],
                 :set     => Proc.new { |md| @binary_files = md[1] },
                 :rc   => %w{ binary-files },
               },
               {
                 :tags => %w{ --size-limit },
                 :arg  => [ :integer ],
                 :set  => Proc.new { |val| @size_limit = val }
               },
               {
                 :tags => %w{ --text-color },
                 :arg  => [ :string ],
                 :set  => Proc.new { |val| @text_highlights = [ make_highlight "text-color", val ] }
               },
               {
                 :tags => %w{ --file-color },
                 :arg  => [ :string ],
                 :set  => Proc.new { |val| @file_highlight = make_highlight "file-color", val }
               },
               {
                 :tags => %w{ -f --file },
                 :arg  => [ :string ],
                 :set  => Proc.new { |fname| @expr = ExpressionFactory.new.read_file fname }
               },
               {
                 :tags => %w{ -o -a },
                 :set  => Proc.new do |md, opt, args|
                   args.unshift opt
                   @expr = ExpressionFactory.new.make_expression args
                 end
               },
               {
                 :res => [ Regexp.new '^ -0 (\d{1,3})? $ ', Regexp::EXTENDED ],
                 :set => Proc.new { |md| rs = md ? md[1] : 0; set_record_separator rs }
               }
              ]
    
    @optset = OptProc::OptionSet.new optdata
    
    reset
  end

  def range
    @range_option.range
  end

  def range= rg
    @range_option.range = rg
  end

  def [] name
    instance_eval "@" + name.to_s
  end

  def reset
    @after                 = 0          # lines of context before the match
    @before                = 0          # lines of context after the match
    @binary_files          = "binary"   # 
    @count                 = false      # just count the lines
    @directory             = "read"     # read, skip, or recurse, a la grep
    @expr                  = nil        # the expression to be evaluated
    @exclude_matching      = false      # exclude files whose names match the expression
    @explain               = false      # display a legible version of the expression
    @extended              = false      # whether to use extended regular expressions
    @extract_matches       = false      # whether to show _only_ the part that matched
    @file_names_only       = false      # display only the file names
    @filter                = true       # display only matches
    @invert_match          = false      # display non-matching lines
    @nocase                = false      # match case
    @match_limit           = nil        # the maximum number of matches to display per file
    @multiline             = false      # whether to use multiline regexps
    @local_config_files    = false      # use local .glarkrc files
    @quiet                 = false      # minimize warnings
    @range_option.range    = nil        # range to start and stop searching; nil => the entire file
    @show_line_numbers     = true       # display numbers of matching lines
    @show_file_names       = nil        # show the names of matching files; nil == > 1; true == >= 1; false means never
    @verbose               = nil        # display debugging output
    @whole_lines           = false      # true means patterns must match the entire line
    @whole_words           = false      # true means all patterns are '\b'ed front and back
    @write_null            = false      # in @file_names_only mode, write '\0' instead of '\n'
    @with_basename         = nil        # match files with this basename
    @without_basename      = nil        # match files without this basename
    @with_fullname         = nil        # match files with this fullname
    @without_fullname      = nil        # match files without this fullname
    @split_as_path         = true       # whether to split arguments that include the path separator

    @highlight             = "multi"    # highlight matches (using ANSI codes)

    @text_highlights       = []
    @file_highlight        = nil
    @line_number_highlight = nil

    @label                 = nil
    @size_limit            = nil
    @out                   = $stdout

    $/ = "\n"
    
    set_output_style "ansi"

    reset_colors
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

  def highlight? str
    %w{ multi on true yes }.detect { |x| str == x }
  end

  def reset_colors
    if @highlight && @highlighter
      @text_highlights       = case @highlight
                               when highlight?(@highlight), true
                                 multi_colors
                               when "single"
                                 single_color
                               when "none", "off", "false", "no", nil, false
                                 []
                               else
                                 warn "highlight format '" + @highlight.to_s + "' not recognized"
                                 single_color
                               end
      @file_highlight        = @highlighter.make "reverse bold"
      @line_number_highlight = nil
    else
      @text_highlights       = []
      @file_highlight        = nil
      @line_number_highlight = nil
    end
  end

  def set_highlight type
    @highlight = type
    reset_colors
  end

  def set_output_style output
    @output      = output

    @highlighter = case @output
                   when "ansi", "xterm"
                     Text::ANSIHighlighter
                   when "grep"
                     @highlight         = false
                     @show_line_numbers = false
                     @after             = 0
                     @before            = 0
                     nil
                   when "text", "match"
                     @highlight         = nil
                     nil
                   end
    
    reset_colors
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
      set_output_style "grep"
    end

    read_options

    validate
  end

  def read_home_rcfiles
    if hd = Env.home_directory
      hd = Pathname.new hd
      homerc = hd + ".glarkrc"
      read_rcfile homerc
    end
  end

  def read_local_rcfiles
    dir = Pathname.new(".").expand_path
    while !dir.root? && dir != hd
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

  def read_rcfile rcfile
    return unless rcfile.exist?

    rcfile.readlines.each do |line|
      line.sub! Regexp.new('\s*#.*'), ''
      line.chomp!
      name, value = line.split Regexp.new('\s*[=:]\s*')
      next unless name && value

      # rc association is somewhat supported:
      @optset.options.each do |option|
        if option.match_rc? name
          val = option.convert_value value
          option.set val
          next
        end
      end

      case name
      when "expression"
        # this should be more intelligent than just splitting on whitespace:
        @expr = ExpressionFactory.new.make_expression value.split(/\s+/)
      when "file-color"
        @file_highlight = make_highlight name, value
      when "filter"
        @filter = to_boolean value
      when "grep"
        set_output_style("grep") if to_boolean value
      when "highlight"
        @highlight = value
      when "ignore-case"
        @nocase = to_boolean value
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
        @text_highlights = [ make_highlight name, value ]
      when %r{^text\-color\-(\d+)$}
        @text_highlights[$1.to_i] = make_highlight name, value
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
    if hl = self.class.instance.highlighter
      if value
        hl.make value
      else
        error opt + " requires a color"
        exit 2
      end
    else
      log { "no highlighter defined" }
    end
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
        @expr = ExpressionFactory.new.make_expression @args, !known_end
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
    
    @expr = nil
    
    nil while @args.size > 0 && @optset.process_option(@args)

    unless @expr
      read_expression
    end
  end

  def write_configuration
    fields = {
      "after-context" => @after,
      "before-context" => @before,
      "binary-files" => @binary_files,
      "file-color" => @file_highlight,
      "filter" => @filter,
      "highlight" => @highlight,
      "ignore-case" => @nocase,
      "known-nontext-files" => FileTester.nontext_extensions.sort.join(' '),
      "known-text-files" => FileTester.text_extensions.sort.join(' '),
      "line-number-color" => @line_number_highlight,
      "local-config-files" => @local_config_files,
      "output" => @output,
      "quiet" => @quiet,
      "size-limit" => @size_limit,
      "split-as-path" => @split_as_path,
      "text-color" => @text_highlights.join(' '),
      "verbose" => @verbose,
    }
    
    fields.keys.sort.each do |fname|
      puts  
      puts "#{fname}: #{fields[fname]}"
    end
  end

  def dump_all_fields
    fields = {
      "after" => @after,
      "before" => @before,
      "binary_files" => @binary_files,
      "count" => @count,
      "directory" => @directory,
      "exclude_matching" => @exclude_matching,
      "explain" => @explain,
      "expr" => @expr,
      "extract_matches" => @extract_matches,
      "file_highlight" => @file_highlight ? @file_highlight.highlight("filename") : "filename",
      "file_names_only" => @file_names_only,
      "filter" => @filter,
      "highlight" => @highlight,
      "invert_match" => @invert_match,
      "known_nontext_files" => FileTester.nontext_extensions.join(", "),
      "known_text_files" => FileTester.text_extensions.join(", "),
      "label" => @label,
      "line_number_highlight" => @line_number_highlight ? @line_number_highlight.highlight("12345") : "12345",
      "local_config_files" => @local_config_files,
      "match_limit" => @match_limit,
      "nocase" => @nocase,
      "output" => @output,
      "quiet" => @quiet,
      "ruby version" => RUBY_VERSION,
      "show_file_names" => @show_file_names,
      "show_line_numbers" => @show_line_numbers,
      "text_highlights" => @text_highlights.compact.collect { |hl| hl.highlight("text") }.join(", "),
      "verbose" => @verbose,
      "version" => Glark::VERSION,
      "whole_lines" => @whole_lines,
      "whole_words" => @whole_words,
      "with-basename" => @with_basename,
      "without-basename" => @without_basename,
      "with-fullname" => @with_fullname,
      "without-fullname" => @without_fullname,
      "write_null" => @write_null,
    }

    len = fields.keys.collect { |f| f.length }.max
    
    fields.keys.sort.each do |field|
      printf "%*s : %s\n", len, field, fields[field]
    end
  end

  # check options for collisions/data validity
  def validate
    range = self.range
    return true if range.nil?
    begin
      range.valid?
    rescue Glark::RangeError => e
      $stderr.puts e
      exit 2
    end
  end

  def show_version
    puts Glark::PACKAGE + ", version " + Glark::VERSION
    puts "Written by Jeff Pace (jeugenepace@gmail.com)."
    puts "Released under the Lesser GNU Public License."
    exit 0
  end
end

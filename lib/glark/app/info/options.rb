#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

require 'glark/app/help'
require 'glark/util/options'

module Glark
  PACKAGE = 'glark'
  VERSION = '1.10.2'
  
  class InfoOptions < Options
    attr_reader :colors
    attr_reader :explain

    def initialize colors, optdata
      @colors = colors
      @explain = false      # display a legible version of the expression

      add_as_options optdata
    end

    def config_fields
      {
        "known-nontext-files" => FileType.nontext_extensions.sort.join(' '),
        "known-text-files" => FileType.text_extensions.sort.join(' '),
        "quiet" => Log.quiet,
        "verbose" => Log.verbose,
      }
    end

    def dump_fields
      {
        "explain" => @explain,
        "known_nontext_files" => FileType.nontext_extensions.join(", "),
        "known_text_files" => FileType.text_extensions.join(", "),
        "quiet" => Log.quiet,
        "ruby version" => RUBY_VERSION,
        "verbose" => Log.verbose,
        "version" => Glark::VERSION,
      }
    end

    def update_fields fields
      fields.each do |name, values|
        case name
        when "known-nontext-files"
          values.last.split.each do |ext|
            FileType.set_nontext ext
          end
        when "known-text-files"
          values.last.split.each do |ext|
            FileType.set_text ext
          end
        when "quiet"
          Log.quiet = to_boolean(values.last)
        when "verbose"
          Log.verbose = to_boolean(values.last) ? 1 : nil
        when "verbosity"
          Log.verbose = values.last.to_i
        end
      end
    end
    
    def add_as_options optdata
      add_opt_blk(optdata, %w{ -V --version }) { show_version }
      add_opt_blk(optdata, %w{ --verbose }) { Log.verbose = true }
      add_opt_blk(optdata, %w{ -? --help }) { Help.new.show_usage; exit 0 }
      add_opt_blk(optdata, %w{ --man }) { Help.new.show_man; exit 0 }
      
      add_opt_true optdata, :explain, %w{ --explain }

      add_opt_blk(optdata, %w{ -q -s --quiet --messages }) { Log.quiet = true }
      add_opt_blk(optdata, %w{ -Q -S --no-quiet --no-messages }) { Log.quiet = false }
    end

    def show_version
      puts Glark::PACKAGE + ", version " + Glark::VERSION
      puts "Written by Jeff Pace (jeugenepace@gmail.com)."
      puts "Released under the Lesser GNU Public License."
      exit 0
    end
  end
end

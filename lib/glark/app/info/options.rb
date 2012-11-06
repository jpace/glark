#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/app/help'
require 'glark/util/optutil'

module Glark; end

class Glark::InfoOptions
  include Loggable, Glark::OptionUtil

  attr_reader :colors
  attr_reader :explain

  def initialize colors, optdata
    @colors = colors

    @explain = false      # display a legible version of the expression

    add_as_options optdata
  end

  def config_fields
    fields = {
      "known-nontext-files" => FileType.nontext_extensions.sort.join(' '),
      "known-text-files" => FileType.text_extensions.sort.join(' '),
      "quiet" => Log.quiet,
      "verbose" => Log.verbose,
    }
  end

  def dump_fields
    fields = { 
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
    fields.each do |name, value|
      case name
      when "known-nontext-files"
        value.split.each do |ext|
          FileType.set_nontext ext
        end
      when "known-text-files"
        value.split.each do |ext|
          FileType.set_text ext
        end
      when "quiet"
        Log.quiet = to_boolean(value)
      when "verbose"
        Log.verbose = to_boolean(value) ? 1 : nil
      when "verbosity"
        Log.verbose = value.to_i
      end
    end
  end

  def add_as_options optdata
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
      :set  => Proc.new { GlarkHelp.new.show_usage; exit 0 }
    }

    optdata << man_option = {
      :tags => %w{ --man },
      :set  => Proc.new { GlarkHelp.new.show_man; exit 0 }
    }
    
    optdata << explain_option = {
      :tags => %w{ --explain },
      :set  => Proc.new { @explain = true }
    }
    
    optdata << quiet_option = {
      :tags => %w{ -q -s --quiet --messages },
      :set  => Proc.new { Log.quiet = true }
    }

    optdata << noquiet_option = {
      :tags => %w{ -Q -S --no-quiet --no-messages },
      :set  => Proc.new { Log.quiet = false }
    }
  end

  def show_version
    puts Glark::PACKAGE + ", version " + Glark::VERSION
    puts "Written by Jeff Pace (jeugenepace@gmail.com)."
    puts "Released under the Lesser GNU Public License."
    exit 0
  end
end

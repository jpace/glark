#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'glark/app/help'

module Glark; end

class Glark::InfoOptions
  include Loggable

  attr_reader :colors
  attr_reader :explain

  def initialize colors
    @colors = colors

    @explain = false      # display a legible version of the expression
  end

  def dump_fields
    fields = { 
      "explain" => @explain 
    }
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

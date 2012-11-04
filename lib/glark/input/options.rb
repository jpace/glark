#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# Options for input.

require 'rubygems'
require 'riel/log'
require 'glark/input/range'
require 'glark/util/optutil'

class InputOptions
  include Loggable, Glark::OptionUtil  

  attr_reader :range            # range to start and stop searching; nil => the entire file
  attr_reader :directory        # read, skip, or recurse, a la grep

  def initialize
    @range = Glark::Range.new 
    @directory = "read"
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

  def config_fields
    fields = {
    }
  end

  def dump_fields
    fields = {
      "directory" => @directory,
    }
  end

  def update_fields fields
  end

  def add_as_options optdata    
    optdata << record_separator_option = {
      :res => [ Regexp.new '^ -0 (\d{1,3})? $ ', Regexp::EXTENDED ],
      :set => Proc.new { |md| rs = md ? md[1] : 0; set_record_separator rs }
    }

    @range.add_as_option optdata

    optdata << directory_option = {
      :tags => %w{ -d },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @directory = val }
    }

    optdata << recurse_option = {
      :tags => %w{ -r --recurse },
      :set  => Proc.new { @directory = "recurse" }
    }

    optdata << dir_option = {
      :tags => %w{ --directories },
      :arg  => [ :string ],
      :set  => Proc.new { |val| @directory = val }
    }

  end
end

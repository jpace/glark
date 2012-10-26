#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# An extended grep, with extended functionality including full regular
# expressions, contextual output, highlighting, detection and exclusion of
# nontext files, and complex matching criteria.

require 'rubygems'
require 'riel'
require 'glark/app/options'
require 'glark/app/runner'

module Glark
end

# The app.
class Glark::App
  include Loggable

  def initialize
    begin
      Log.set_widths(-15, -40, -40)
      
      Log.log { "loading options" }
      opts = GlarkOptions.instance
      
      opts.run ARGV 
      Log.log { "done loading options" }

      # To get rid of the annoying stack trace on ctrl-C:
      trap("INT") { abort }
      
      if opts.explain
        puts opts.expr.explain
      end

      files = if ARGV.size > 0 then
                if opts.split_as_path
                  ARGV.collect { |f| f.split File::PATH_SEPARATOR  }.flatten
                else
                  ARGV
                end
              else 
                [ '-' ]
              end

      glark = Glark::Runner.new opts.expr, files 

      files.each do |f|
        glark.search f  
      end

      glark.end_processing

      exit glark.exit_status
    rescue => e
      # show the message, and the stack trace only if verbose:
      $stderr.puts "error: #{e}"
      if opts.verbose || true
        $stderr.puts e.backtrace
        raise
      else
        exit 2
      end
    end
  end
end

if __FILE__ == $0
  Glark::App.new
end

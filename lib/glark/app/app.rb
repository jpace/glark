#!/usr/bin/ruby -w
#!ruby -w
# vim: set filetype=ruby : set sw=2

# An extended grep, with extended functionality including full regular
# expressions, contextual output, highlighting, detection and exclusion of
# nontext files, and complex matching criteria.

require 'glark/app/options'
require 'glark/app/runner'

module Glark
  class App
    def initialize
      begin
        Log.set_widths(-15, -40, -40)
        
        opts = AppOptions.new
        opts.run ARGV
        
        # To get rid of the annoying stack trace on ctrl-C:
        trap("INT") { abort }
        
        if opts.info_options.explain
          puts opts.match_spec.expr.explain
        end

        files = ARGV.size > 0 ? ARGV : [ '-' ]
        runner = Runner.new opts, files
        
        exit runner.exit_status
      rescue => e
        # show the message, and the stack trace only if verbose:
        $stderr.puts "error: #{e}"
        if Log.verbose
          $stderr.puts e.backtrace
          raise
        else
          exit 2
        end
      end
    end
  end
end

if __FILE__ == $0
  Glark::App.new
end

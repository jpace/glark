#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pathname'
require 'tempfile'
require 'stringio'
require 'glark/tc'
require 'glark/app/options'
require 'glark/util/timestamper'

module Glark
  class AppTestCase < Glark::TestCase
    include TimeStamper
    
    def setup
      # ignore what they have in ENV[HOME]    
      ENV['HOME'] = '/this/should/not/exist'
      super
    end

    def teardown
      super
    end

    def run_glark args, *files
      gopt = AppOptions.new
      sio = StringIO.new
      gopt.run(args + files)
      gopt.output_options.out = sio

      Runner.new gopt, gopt.fileset
      
      sio.close

      if false
        puts "....."
        puts sio.string
        puts "....."
      end
      
      sio.string
    end

    def run_app_test expected, args, *files
      result = run_glark args, *files
      actual = result.split "\n"
      ( 0 ... [ expected.length, actual.length ].max ).each do |idx|
        assert_equal expected[idx], actual[idx], "idx: #{idx}"
      end
    end

    def run_app_test_exact_output expected, args, *files
      result = run_glark args, *files
      assert_equal expected, result
    end

    def assert_file_filter_pattern_eq exppat, opts, field, posneg, cls
      expre = Regexp.new exppat
      assert_file_filter_eq expre, opts, field, posneg, cls, :pattern
    end

    def assert_file_filter_eq expval, opts, field, posneg, cls, matchfield
      criteria = opts.input_spec.file_criteria
      assert_filter_eq expval, criteria, field, posneg, cls, matchfield
    end

    def assert_directory_filter_pattern_eq exppat, opts, field, posneg, cls
      expre = Regexp.new exppat
      assert_directory_filter_eq expre, opts, field, posneg, cls, :pattern
    end

    def assert_directory_filter_eq expval, opts, field, posneg, cls, matchfield
      criteria = opts.input_spec.dir_criteria
      assert_filter_eq expval, criteria, field, posneg, cls, matchfield
    end
    
    def assert_filter_eq expval, criteria, field, posneg, cls, matchfield
      pncrit = criteria.get field, posneg
      pncrit.each do |crit|
        matchval = crit.send matchfield
        if expval == matchval
          assert true
          return
        end
      end

      assert false, "no match: #{matchfield}; #{expval}"
    end
  end
end

#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pathname'
require 'tempfile'
require 'tc'
require 'glark/app/options'

class Glark::AppTestCase < Glark::TestCase
  def setup
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  def run_glark args, *files
    info "files: #{files}"
    gopt = Glark::AppOptions.new
    sio = StringIO.new
    gopt.run(args + files)
    gopt.out = sio

    Log.verbose = true

    glark = Glark::Runner.new gopt, gopt.files
    
    sio.close
    puts ">>>>>"
    puts sio.string
    puts "<<<<<"
    
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
    criteria = opts.input_options.file_filters.criteria
    assert_filter_eq expre, criteria, field, posneg, cls, :pattern
  end

  def assert_file_filter_eq expval, opts, field, posneg, cls, matchfield
    criteria = opts.input_options.file_filters.criteria
    assert_filter_eq expval, criteria, field, posneg, cls, matchfield
  end

  def assert_directory_filter_pattern_eq exppat, opts, field, posneg, cls
    expre = Regexp.new exppat
    criteria = opts.input_options.directory_filters.criteria
    assert_filter_eq expre, criteria, field, posneg, cls, :pattern
  end

  def assert_directory_filter_eq expval, opts, field, posneg, cls, matchfield
    criteria = opts.input_options.directory_filters.criteria
    assert_filter_eq expval, criteria, field, posneg, cls, matchfield
  end
  
  def assert_filter_eq expval, criteria, field, posneg, cls, matchfield
    pncrit = criteria.get(field, posneg)

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

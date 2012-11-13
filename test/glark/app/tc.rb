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
end

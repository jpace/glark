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

  def run_app_test expected, args, *files
    info "files: #{files}"
    gopt = Glark::Options.instance
    sio = StringIO.new
    gopt.run args
    gopt.out = sio

    Log.verbose = true

    glark = Glark::Runner.new gopt.expr, files
    files.each do |file|
      info "file: #{file}".red
      glark.search file
      info "file: #{file}".on_red
    end
    
    sio.close
    puts ">>>>>".yellow
    puts sio.string
    puts "<<<<<".yellow
    
    assert_equal expected.collect { |line| "#{line}\n" }.join(''), sio.string

    gopt.reset
  end
end
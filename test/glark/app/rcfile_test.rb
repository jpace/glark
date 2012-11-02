#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pathname'
require 'tempfile'
require 'tc'
require 'glark/app/options'

class Glark::RcfileTestCase < Glark::TestCase
  def setup
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  def run_option_test args, exp, &blk
    gopt = Glark::Options.new
    gopt.run args

    exp.each do |name, expval|
      val = gopt.method(name).call
      assert_equal expval, val
    end
    
    blk.call(gopt) if blk
  end

  def test_simple
    run_option_test(%w{ foo }, []) do |opts|
      # default values
      assert_equal "multi", opts.colors.text_color_style
      assert_equal false, opts.local_config_files

      opts.read_rcfile Pathname.new '/proj/org/incava/glark/test/resources/rcfile.txt'

      assert_equal "single", opts.colors.text_color_style
      assert_equal true, opts.local_config_files
      assert_equal [ "bold", "red" ], opts.colors.line_number_highlight.colors
      assert opts.match_options.ignorecase
      assert_equal 1000, opts.size_limit
      assert_equal [ "underline", "magenta" ], opts.match_options.text_highlights[3].colors
    end
  end
end

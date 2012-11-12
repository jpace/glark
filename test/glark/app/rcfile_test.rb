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
    gopt = Glark::AppOptions.new
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
      assert_equal 1000, opts.input_options.file_filters.negative.find_by_class(SizeLimitFilter).max_size
      assert_equal [ "underline", "magenta" ], opts.match_options.text_highlights[3].colors
    end
  end

  def test_grep
    run_option_test(%w{ foo }, []) do |opts|
      # default values
      assert_equal "glark", opts.output_options.style

      opts.read_rcfile Pathname.new '/proj/org/incava/glark/test/resources/rcgrep.txt'

      assert_equal "grep", opts.output_options.style
    end
  end

  def assert_has_filter_pattern exppat, filters, cls
    clsfilters = filters.select { |pf| pf.kind_of? cls }
    assert clsfilters.detect { |filter| filter.pattern == Regexp.new(exppat) }, "exppat: #{exppat}; cls: #{cls}"
  end

  def test_match
    run_option_test(%w{ foo }, []) do |opts|
      opts.read_rcfile Pathname.new '/proj/org/incava/glark/test/resources/rcmatch.txt'

      posfilters = opts.input_options.file_filters.positive
      assert_has_filter_pattern '\w+.java', posfilters, BaseNameFilter
      assert_has_filter_pattern '\w+.rb', posfilters, BaseNameFilter

      negfilters = opts.input_options.file_filters.negative
      assert_has_filter_pattern 'zxcdjlk', negfilters, BaseNameFilter
    end
  end

  def test_path
    run_option_test(%w{ foo }, []) do |opts|
      opts.read_rcfile Pathname.new '/proj/org/incava/glark/test/resources/rcpath.txt'

      posfilters = opts.input_options.directory_filters.positive
      assert_has_filter_pattern 'src/main/java', posfilters, FullNameFilter
      assert_has_filter_pattern 'src/test/ruby', posfilters, FullNameFilter

      negfilters = opts.input_options.directory_filters.negative
      assert_has_filter_pattern 'org/incava/util', negfilters, FullNameFilter
    end
  end
end

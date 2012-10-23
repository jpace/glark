#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pathname'
require 'tempfile'

testdir = Pathname.new(__FILE__).expand_path.dirname.to_s
$:.unshift testdir

require 'tc'
require 'glark/options'

class TC_Options < GlarkTestCase

  def setup
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  DEFAULTS = {
    :after                 => 0,
    :before                => 0,
    :binary_files          => "binary",
    :count                 => false,
    :directory             => "read",
    :exclude_matching      => false,
    :explain               => false,
    :expr                  => nil,
    :extract_matches       => false,
    # :file_highlight        => nil,
    :file_names_only       => false,
    :filter                => true,
    :highlight             => "multi",
    :invert_match          => false,
    :label                 => nil,
    :line_number_highlight => nil,
    :local_config_files    => false,
    :match_limit           => nil,
    :nocase                => false,
    :out                   => $stdout,
    :quiet                 => false,
    :range_end             => nil,
    :range_start           => nil,
    :show_break            => false,
    :show_file_names       => nil,
    :show_line_numbers     => true,
    :size_limit            => nil,
    :split_as_path         => true,
    :text_highlights       => GlarkOptions.instance.multi_colors,
    :verbose               => nil,
    :whole_lines           => false,
    :whole_words           => false,
    :with_basename         => nil,
    :with_fullname         => nil,
    :without_basename      => nil,
    :without_fullname      => nil,
    :write_null            => false,
  }
  
  def do_test(args, exp, &blk)
    Log.level = Log::DEBUG
    # info "args: #{args}".red
    expected = DEFAULTS.merge exp

    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'

    origargs = args.dup
    
    gopt = GlarkOptions.instance
    gopt.run args

    expected.sort { |a, b| a[0].to_s <=> b[0].to_s }.each do |opt, expval|
      expstr = "expclass: #{expval.class}; expval: #{expval.inspect}; origargs: #{origargs.inspect}"
      [ gopt.method(opt).call, gopt[opt] ].each do |val|
        if val.kind_of? Array
          assert_equal expval.length, val.length, "option: #{opt}; exp length: #{expval.length}; act length: #{val.length}; " + expstr
          (0 ... expval.length).each do |idx|
            assert_equal expval[idx], val[idx], "option: #{opt}; index: #{idx}; exp: #{expval.inspect}; act: #{val.inspect}; " + expstr
          end
        else
          assert_equal expval, val, "option: #{opt}; exp: #{expval.inspect}; act: #{val.inspect}; " + expstr
        end
      end
    end
    
    blk.call(gopt) if blk

    gopt.reset
  end

  def test_default_values
    do_test(%w{ foo file1 file2 },
            { 
              :expr => RegexpFuncObj.new(%r{foo}, 0)
            })
  end

  def test_extract_match
    do_test(%w{ --extract-matches foo file1 file2 },
            { 
              :extract_matches => true,
              :expr            => RegexpFuncObj.new(%r{foo}, 0)
            })
  end

  def test_extract_match_incomplete
    str = '--extract-matches'
    (5 ... str.length - 1).each do |idx|
      tag = str[0 .. idx]
      do_test([ tag ] | %w{ foo file1 file2 },
              { 
                :extract_matches => true,
                :expr            => RegexpFuncObj.new(%r{foo}, 0)
              })
    end
  end

  def test_record_separator
    %w{ -0 -00 -000 }.each do |arg|
      $/ = "\n"
      do_test([ arg ] | %w{ foo file1 file2 } ,
              { 
                :expr => RegexpFuncObj.new(%r{foo}, 0)
              }) do |gopt|
        assert_equals "\n\n", $/
      end
    end
  end
  
  def test_short_options
    [ 
      %w{ -rli      },
      %w{ -rl    -i },
      %w{ -r    -li },
      %w{ -r  -l -i },
    ].each do |args|
      do_test(args | %w{ foo },
              { 
                :directory       => "recurse",
                :expr            => RegexpFuncObj.new(%r{foo}i, 0),
                :file_names_only => true,
                :nocase          => true,
              })
    end
  end

  def test_context_default
    %w{ -C --context }.each do |ctx|
      args = [ ctx, 'foo' ]
      do_test(args,
              { 
                :after           => 2,
                :before          => 2,
                :expr            => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_context_specified
    [ 3, 1, 666 ].each do |val|
      vstr = val.to_s
      [
        [ '-C',                vstr ],
        [ '--context',         vstr ],
        [ '--context=' + vstr,      ]
      ].each do |args|
        do_test(args | %w{ foo },
                { 
                  :after           => val,
                  :before          => val,
                  :expr            => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
    
    vals = (1 .. 10).to_a  | (1 .. 16).collect { |x| 2 ** x }
    vals.each do |val|
      args = [ '-' + val.to_s, 'foo' ]
      do_test(args,
              { 
                :after           => val,
                :before          => val,
                :expr            => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_after_context
    [ 3, 1, 666 ].each do |val|
      vstr = val.to_s
      [
        [ '-A',                vstr ],
        [ '--after-context',   vstr ],
        [ '--after-context=' + vstr ]
      ].each do |args|
        do_test(args | %w{ foo },
                { 
                  :after           => val,
                  :expr            => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_before_context
    [ 3, 1, 666 ].each do |val|
      vstr = val.to_s
      [
        [ '-B',                 vstr ],
        [ '--before-context',   vstr ],
        [ '--before-context=' + vstr ]
      ].each do |args|
        do_test(args | %w{ foo },
                { 
                  :before          => val,
                  :expr            => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_highlight
    %w{ -u --highlight }.each do |hlopt|
      do_test([ hlopt, 'foo' ],
              { 
                :highlight       => "multi",
                :expr            => RegexpFuncObj.new(%r{foo}, 0),
              })
    end

    %w{ multi }.each do |val|
      [
        [ '--highlight=' + val ],
        [ '--highlight',   val ],
      ].each do |opt|
        do_test(opt | [ 'foo' ],
                { 
                  :highlight       => val,
                  :expr            => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end

    singlecolor = Text::ANSIHighlighter.make(Text::Highlighter::DEFAULT_COLORS[0])

    %w{ single }.each do |val|
      [
        [ '--highlight=' + val ],
        [ '--highlight',   val ],
      ].each do |opt|
        do_test(opt | [ 'foo' ],
                { 
                  :highlight       => val,
                  :text_highlights => [ singlecolor ],
                  :expr            => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end

    %w{ none }.each do |val|
      do_test([ '--highlight=' + val, 'foo' ],
              { 
                :highlight       => nil,
                :text_highlights => [],
                :expr            => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_no_highlight
    %w{ -U --no-highlight }.each do |hlopt|
      do_test([ hlopt, 'foo' ],
              { 
                :highlight       => nil,
                :text_highlights => [],
                :expr            => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end
  
  def test_verbose
    if origverb = Log.verbose

      %w{ --verbose --verbosity }.each do |vtag|
        [ nil, 1, 2, 3, 4 ].each do |num|
          vopt = vtag
          if num
            vopt += "=" + num.to_s
          end
          Log.verbose = nil
          do_test([ vopt, 'foo' ],
                  { 
                    :expr            => RegexpFuncObj.new(%r{foo}, 0),
                  }) do |opts|
            assert_equals true, Log.verbose, "log verbosity"
          end
        end
      end

      Log.verbose = origverb
    end
  end
  
  def test_invert_match
    %w{ -v --invert-match }.each do |vopt|
      do_test([ vopt, 'foo' ],
              { 
                :invert_match    => true,
                :expr            => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end
  
  def test_ignore_case
    %w{ -i --ignore-case }.each do |opt|
      do_test([ opt, 'foo' ],
              { 
                :nocase          => true,
                :expr            => RegexpFuncObj.new(%r{foo}i, 0),
              })
    end
  end
  
  def test_filter
    %w{ --filter }.each do |opt|
      do_test([ opt, 'foo' ],
              { 
                :filter          => true,
                :expr            => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end
  
  def test_no_filter
    %w{ --no-filter --nofilter }.each do |opt|
      do_test([ opt, 'foo' ],
              { 
                :filter          => false,
                :expr            => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end
  
  def test_output_type
    %w{ -g --grep }.each do |opt|
      do_test([ opt, 'foo' ],
              { 
                :output            => "grep",
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
                :highlight         => false,
                :text_highlights   => [],
                :show_line_numbers => false,
                :after             => 0,
                :before            => 0,
              })
    end
  end
  
  def test_line_number
    %w{ -n --line-number }.each do |opt|
      do_test([ opt, 'foo' ],
              { 
                :show_line_numbers => true,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_no_line_number
    %w{ -N --no-line-number }.each do |opt|
      do_test([ opt, 'foo' ],
              { 
                :show_line_numbers => false,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_explain
    %w{ --explain }.each do |opt|
      do_test([ opt, 'foo' ],
              { 
                :explain           => true,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_quiet
    %w{ -q -s --quiet --messages }.each do |opt|
      do_test([ opt, 'foo' ],
              { 
                :quiet             => true,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_no_quiet
    %w{ -Q -S --no-quiet --no-messages }.each do |opt|
      do_test([ opt, 'foo' ],
              { 
                :quiet             => false,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_whole_words
    %w{ -w --word --word-regexp }.each do |opt|
      do_test([ opt, 'foo' ],
              { 
                :whole_words       => true,
                :expr              => RegexpFuncObj.new(%r{\bfoo\b}, 0),
              })
    end
  end

  def test_whole_lines
    %w{ -x --line-regexp }.each do |opt|
      do_test([ opt, 'foo' ],
              { 
                :whole_lines       => true,
                :expr              => RegexpFuncObj.new(%r{^foo$}, 0),
              })
    end
  end

  def test_files_with_matches
    %w{ -l --files-with-matches }.each do |opt|
      do_test([ opt, 'foo' ],
              {
                :file_names_only   => true,
                :invert_match      => false,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_files_without_matches
    %w{ -L --files-without-match }.each do |opt|
      do_test([ opt, 'foo' ],
              {
                :file_names_only   => true,
                :invert_match      => true,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_count
    %w{ -c --count }.each do |opt|
      do_test([ opt, 'foo' ],
              {
                :count             => true,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_write_null
    %w{ -Z --null }.each do |opt|
      do_test([ opt, 'foo' ],
              {
                :write_null        => true,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_exclude_matching
    %w{ -M --exclude-matching }.each do |opt|
      do_test([ opt, 'foo' ],
              {
                :exclude_matching  => true,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_directory_short
    %w{ read recurse skip }.each do |opt|
      do_test([ '-d', opt, 'foo' ],
              {
                :directory         => opt,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end
  
  def test_recurse
    %w{ -r --recurse }.each do |opt|
      do_test([ opt, 'foo' ],
              {
                :directory         => 'recurse',
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_extract_matches
    %w{ -y --extract-matches }.each do |opt|
      do_test([ opt, 'foo' ],
              {
                :extract_matches   => true,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_no_split_as_path
    %w{ --no-split-as-path }.each do |opt|
      do_test([ opt, 'foo' ],
              {
                :split_as_path     => false,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def do_split_as_path_test(exp, args)
    args.each do |val|
      [ 
        [ '--split-as-path',   val ],
        [ '--split-as-path=' + val ]
      ].each do |opt|
        do_test(opt | [ 'foo' ],
                {
                  :split_as_path     => exp,
                  :expr              => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_split_as_path
    do_test([ '--split-as-path', 'foo' ],
            {
              :split_as_path     => true,
              :expr              => RegexpFuncObj.new(%r{foo}, 0),
            })
    
    do_split_as_path_test(true,  %w{ true  on  yes })
    do_split_as_path_test(false, %w{ false off no  })
  end

  def test_directory_long
    %w{ read recurse skip }.each do |val|
      [
        [ '--directories=' + val ],
        [ '--directories',   val ]
      ].each do |args|
        do_test(args | %w{ foo },
                {
                  :directory         => val,
                  :expr              => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_no_show_file_names
    %w{ -h --no-filename }.each do |opt|
      do_test([ opt, 'foo' ],
              {
                :show_file_names   => false,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_show_file_names
    %w{ -H --with-filename }.each do |opt|
      do_test([ opt, 'foo' ],
              {
                :show_file_names   => true,
                :expr              => RegexpFuncObj.new(%r{foo}, 0),
              })
    end
  end

  def test_label
    %w{ testing 123 any*char\/acters }.each do |label|
      [
        [ '--label=' + label ],
        [ '--label',   label ]
      ].each do |opt|
        do_test(opt | %w{ foo },
                {
                  :label             => label,
                  :expr              => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_match_limit
    %w{ 1 2 4 20 50 100 2000 30000 }.each do |num|
      [
        [ '-m',                num ],
        [ '--match-limit',     num ],
        [ '--match-limit=' +   num ],
      ].each do |args|
        do_test(args | %w{ foo },
                { 
                  :match_limit     => num.to_i,
                  :expr            => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_with_basename
    %w{ abc123 \w+\S* }.each do |pat|
      %w{ --with-basename --basename --with-name --name }.each do |tag|
        [
          [ tag, pat ],
          [ tag + '=' + pat ]
        ].each do |args|
          do_test(args | %w{ foo },
                  { 
                    :with_basename   => Regexp.new(pat),
                    :expr            => RegexpFuncObj.new(%r{foo}, 0),
                  })
        end
      end
    end
  end

  def test_without_basename
    %w{ abc123 \w+\S* }.each do |pat|
      %w{ --without-basename --without-name }.each do |tag|
        [
          [ tag, pat ],
          [ tag + '=' + pat ]
        ].each do |args|
          do_test(args | %w{ foo },
                  { 
                    :without_basename => Regexp.new(pat),
                    :expr             => RegexpFuncObj.new(%r{foo}, 0),
                  })
        end
      end
    end
  end

  def test_with_fullname
    %w{ abc123 \w+\S* }.each do |pat|
      %w{ --with-fullname --fullname --with-path --path }.each do |tag|
        [
          [ tag, pat ],
          [ tag + '=' + pat ]
        ].each do |args|
          do_test(args | %w{ foo },
                  { 
                    :with_fullname   => Regexp.new(pat),
                    :expr            => RegexpFuncObj.new(%r{foo}, 0),
                  })
        end
      end
    end
  end

  def test_without_fullname
    %w{ abc123 \w+\S* }.each do |pat|
      %w{ --without-fullname --without-path }.each do |tag|
        [
          [ tag, pat ],
          [ tag + '=' + pat ]
        ].each do |args|
          do_test(args | %w{ foo },
                  { 
                    :without_fullname => Regexp.new(pat),
                    :expr             => RegexpFuncObj.new(%r{foo}, 0),
                  })
        end
      end
    end
  end

  def test_range_start
    %w{ 5 5% 10 90% }.each do |rg|
      [
        [ '--after=' + rg ],
        [ '--after',   rg ]
      ].each do |opt|
        do_test(opt | %w{ foo },
                {
                  :range_start      => rg,
                  :expr             => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_range_end
    %w{ 5 5% 10 90% }.each do |rg|
      [
        [ '--before=' + rg ],
        [ '--before',   rg ],
      ].each do |opt|
        do_test(opt | %w{ foo },
                {
                  :range_end        => rg,
                  :expr             => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_range_both
    [
      %w{  5  10  },
      %w{  7  10% },
      %w{ 90% 95% },
      %w{ 18  81  }
    ].each do |from, to|
      [
        [ '--range=' + from + ',' + to ],
        [ '--range',   from + ',' + to ],
      ].each do |opt|
        do_test(opt | %w{ foo },
                {
                  :range_start      => from,
                  :range_end        => to,
                  :expr             => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_binary_files
    %w{ binary without-match text }.each do |val|
      [
        [ '--binary-files="' + val + '"' ],
        [ '--binary-files='  + val ],
        [ '--binary-files',    val ],
      ].each do |opt|
        do_test(opt | %w{ foo },
                {
                  :binary_files     => val,
                  :expr             => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_size_limit
    [ 0, 1, 2, 4, 8, 16, 32, 100, 1000, 10000, 100000 ].each do |val|
      [
        [ '--size-limit=' + val.to_s ],
        [ '--size-limit',   val.to_s ],
      ].each do |opt|
        do_test(opt | %w{ foo },
                {
                  :size_limit       => val,
                  :expr             => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_text_highlight
    [ 'red', 'blue', 'cyan', 'bold blue', 'blue bold' ].each do |color|
      [ 
        [ '-T', color ],
        [ '--text-color="' + color + '"' ],
        [ '--text-color=' + color ],
      ].each do |opt|
        do_test(opt | [ 'foo' ],
                {
                  :text_highlights  => [ Text::ANSIHighlighter.make(color) ],
                  :expr             => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  # this is no longer supported.
  def xxx_test_text_color_numbered
    defaults = Text::Highlighter::DEFAULT_COLORS.collect { |color| Text::ANSIHighlighter.make(color) }
    [ 'red', 'blue', 'cyan', 'bold blue', 'blue bold' ].each do |color|
      (0 .. 5).each do |idx|
        expected = defaults.dup
        expected[idx] = Text::ANSIHighlighter.make color
        [
          [ '--text-color-' + idx.to_s + '="' + color + '"' ],
          [ '--text-color-' + idx.to_s + '=' + color ],
          [ '--text-color-' + idx.to_s, color ],
        ].each do |opt|
        do_test(opt | [ 'foo' ],
                {
                  :text_highlights  => expected,
                  :expr             => RegexpFuncObj.new(%r{foo}, 0),
                })
        end
      end
    end
  end
  
  def test_file_color
    [ 'red', 'blue', 'cyan', 'bold blue', 'blue bold' ].each do |color|
      [ 
        [ '-F', color ],
        [ '--file-color',    color ],
        [ '--file-color="' + color + '"' ],
        [ '--file-color='  + color ],
      ].each do |opt|
        do_test(opt | [ 'foo' ],
                {
                  :file_highlight   => Text::ANSIHighlighter.make(color),
                  :expr             => RegexpFuncObj.new(%r{foo}, 0),
                })
      end
    end
  end

  def test_file_expression
    res = %w{ foo bar baz \w\s+\d\S\W }
    
    t = Tempfile.new "tc_options"
    res.each do |re|
      t.puts re
    end
    t.close

    pt = Pathname.new t.path

    orexpr   = nil
    res.each do |re| 
      refo = RegexpFuncObj.new Regexp.new(re), 0
      if orexpr
        orexpr.ops << refo
      else
        orexpr = InclusiveOrExpression.new refo
      end
    end
    
    begin
      [
        [ '-f',        t.path       ],
        [ '--file="' + t.path + '"' ],
        [ '--file='  + t.path       ],
        [ '--file',    t.path       ],
      ].each do |opt|
        do_test(opt,
                {
                  :expr             => orexpr,
                })
      end
    ensure
      if pt.exist?
        pt.delete
      end
    end
  end

  def test_or_expression
    pats = %w{ foo bar }

    re0, re1 = pats.collect { |pat| RegexpFuncObj.new(Regexp.new(pat), 0) }
    
    orexpr = InclusiveOrExpression.new re0, re1
    
    [ 
      [ '-o', *pats ],
    ].each do |opt|
      do_test(opt,
              {
                :expr             => orexpr,
              })
    end
  end
  
  def test_and_expression
    pats = %w{ foo bar }

    re0, re1 = pats.collect { |pat| RegexpFuncObj.new(Regexp.new(pat), 0) }
    
    exp = AndExpression.new 0, re0, re1
    
    [ 
      [ '-a', 0, *pats ],
    ].each do |opt|
      do_test(opt,
              {
                :expr => exp,
              })
    end
  end
  
end

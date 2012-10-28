#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pathname'
require 'tempfile'
require 'tc'
require 'glark/app/options'

class Glark::OptionsTestCase < Glark::TestCase
  def setup
    # ignore what they have in ENV[HOME]    
    ENV['HOME'] = '/this/should/not/exist'
  end

  def run_option_test args, exp, &blk
    gopt = Glark::Options.instance
    gopt.run args

    exp.each do |name, expval|
      val = gopt.method(name).call
      assert_equal expval, val
    end
    
    blk.call(gopt) if blk

    gopt.reset
  end

  def test_default_values
    run_option_test(%w{ foo file1 file2 },
                    { 
                      :expr => RegexpExpression.new(%r{foo}, 0)
                    })
  end

  def test_extract_match
    run_option_test(%w{ --extract-matches foo file1 file2 },
                    { 
                      :extract_matches => true,
                      :expr            => RegexpExpression.new(%r{foo}, 0)
                    })
  end

  def test_extract_match_incomplete
    str = '--extract-matches'
    (5 ... str.length - 1).each do |idx|
      tag = str[0 .. idx]
      run_option_test([ tag ] | %w{ foo file1 file2 },
                      { 
                        :extract_matches => true,
                        :expr            => RegexpExpression.new(%r{foo}, 0)
                      })
    end
  end

  def test_record_separator
    %w{ -0 -00 -000 }.each do |arg|
      $/ = "\n"
      run_option_test([ arg ] | %w{ foo file1 file2 },
                      { 
                        :expr => RegexpExpression.new(%r{foo}, 0)
                      }) do |gopt|
        assert_equal "\n\n", $/
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
      run_option_test(args + %w{ foo },
                      { 
                        :directory       => "recurse",
                        :expr            => RegexpExpression.new(%r{foo}i, 0),
                        :file_names_only => true,
                        :nocase          => true,
                      })
    end
  end

  def test_context_default
    %w{ -C --context }.each do |ctx|
      args = [ ctx, 'foo' ]
      run_option_test(args,
                      { 
                        :after           => 2,
                        :before          => 2,
                        :expr            => RegexpExpression.new(%r{foo}, 0),
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
        run_option_test(args | %w{ foo },
                        { 
                          :after           => val,
                          :before          => val,
                          :expr            => RegexpExpression.new(%r{foo}, 0),
                        })
      end
    end
    
    vals = (1 .. 10).to_a  | (1 .. 16).collect { |x| 2 ** x }
    vals.each do |val|
      args = [ '-' + val.to_s, 'foo' ]
      run_option_test(args,
                      { 
                        :after           => val,
                        :before          => val,
                        :expr            => RegexpExpression.new(%r{foo}, 0),
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
        run_option_test(args | %w{ foo },
                        { 
                          :after           => val,
                          :expr            => RegexpExpression.new(%r{foo}, 0),
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
        run_option_test(args | %w{ foo },
                        { 
                          :before          => val,
                          :expr            => RegexpExpression.new(%r{foo}, 0),
                        })
      end
    end
  end

  def test_highlight
    %w{ -u --highlight }.each do |hlopt|
      run_option_test([ hlopt, 'foo' ],
                      { 
                        :highlight       => "multi",
                        :expr            => RegexpExpression.new(%r{foo}, 0),
                      })
    end

    %w{ multi }.each do |val|
      [
       [ '--highlight=' + val ],
       [ '--highlight',   val ],
      ].each do |opt|
        run_option_test(opt | [ 'foo' ],
                        { 
                          :highlight       => val,
                          :expr            => RegexpExpression.new(%r{foo}, 0),
                        })
      end
    end

    singlecolor = Text::ANSIHighlighter.make(Text::Highlighter::DEFAULT_COLORS[0])

    %w{ single }.each do |val|
      [
       [ '--highlight=' + val ],
       [ '--highlight',   val ],
      ].each do |opt|
        run_option_test(opt | [ 'foo' ],
                        { 
                          :highlight       => val,
                          :text_highlights => [ singlecolor ],
                          :expr            => RegexpExpression.new(%r{foo}, 0),
                        })
      end
    end

    %w{ none }.each do |val|
      run_option_test([ '--highlight=' + val, 'foo' ],
                      { 
                        :highlight       => nil,
                        :text_highlights => [],
                        :expr            => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_no_highlight
    %w{ -U --no-highlight }.each do |hlopt|
      run_option_test([ hlopt, 'foo' ],
                      { 
                        :highlight       => nil,
                        :text_highlights => [],
                        :expr            => RegexpExpression.new(%r{foo}, 0),
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
          run_option_test([ vopt, 'foo' ],
                          { 
                            :expr            => RegexpExpression.new(%r{foo}, 0),
                          }) do |opts|
            assert_equal true, Log.verbose, "log verbosity"
          end
        end
      end

      Log.verbose = origverb
    end
  end
  
  def test_invert_match
    %w{ -v --invert-match }.each do |vopt|
      run_option_test([ vopt, 'foo' ],
                      { 
                        :invert_match    => true,
                        :expr            => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end
  
  def test_ignore_case
    %w{ -i --ignore-case }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      { 
                        :nocase          => true,
                        :expr            => RegexpExpression.new(%r{foo}i, 0),
                      })
    end
  end
  
  def test_filter
    %w{ --filter }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      { 
                        :filter          => true,
                        :expr            => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end
  
  def test_no_filter
    %w{ --no-filter --nofilter }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      { 
                        :filter          => false,
                        :expr            => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end
  
  def test_output_type
    %w{ -g --grep }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      { 
                        :output            => "grep",
                        :expr              => RegexpExpression.new(%r{foo}, 0),
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
      run_option_test([ opt, 'foo' ],
                      { 
                        :show_line_numbers => true,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_no_line_number
    %w{ -N --no-line-number }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      { 
                        :show_line_numbers => false,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_explain
    %w{ --explain }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      { 
                        :explain           => true,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_quiet
    %w{ -q -s --quiet --messages }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      { 
                        :quiet             => true,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_no_quiet
    %w{ -Q -S --no-quiet --no-messages }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      { 
                        :quiet             => false,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_whole_words
    %w{ -w --word --word-regexp }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      { 
                        :whole_words       => true,
                        :expr              => RegexpExpression.new(%r{\bfoo\b}, 0),
                      })
    end
  end

  def test_whole_lines
    %w{ -x --line-regexp }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      { 
                        :whole_lines       => true,
                        :expr              => RegexpExpression.new(%r{^foo$}, 0),
                      })
    end
  end

  def test_files_with_matches
    %w{ -l --files-with-matches }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      {
                        :file_names_only   => true,
                        :invert_match      => false,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_files_without_matches
    %w{ -L --files-without-match }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      {
                        :file_names_only   => true,
                        :invert_match      => true,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_count
    %w{ -c --count }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      {
                        :count             => true,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_write_null
    %w{ -Z --null }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      {
                        :write_null        => true,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_exclude_matching
    %w{ -M --exclude-matching }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      {
                        :exclude_matching  => true,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_directory_short
    %w{ read recurse skip }.each do |opt|
      run_option_test([ '-d', opt, 'foo' ],
                      {
                        :directory         => opt,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end
  
  def test_recurse
    %w{ -r --recurse }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      {
                        :directory         => 'recurse',
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_extract_matches
    %w{ -y --extract-matches }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      {
                        :extract_matches   => true,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_no_split_as_path
    %w{ --no-split-as-path }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      {
                        :split_as_path     => false,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def do_split_as_path_test(exp, args)
    args.each do |val|
      [ 
       [ '--split-as-path',   val ],
       [ '--split-as-path=' + val ]
      ].each do |opt|
        run_option_test(opt | [ 'foo' ],
                        {
                          :split_as_path     => exp,
                          :expr              => RegexpExpression.new(%r{foo}, 0),
                        })
      end
    end
  end

  def test_split_as_path
    run_option_test([ '--split-as-path', 'foo' ],
                    {
                      :split_as_path     => true,
                      :expr              => RegexpExpression.new(%r{foo}, 0),
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
        run_option_test(args | %w{ foo },
                        {
                          :directory         => val,
                          :expr              => RegexpExpression.new(%r{foo}, 0),
                        })
      end
    end
  end

  def test_no_show_file_names
    %w{ -h --no-filename }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      {
                        :show_file_names   => false,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_show_file_names
    %w{ -H --with-filename }.each do |opt|
      run_option_test([ opt, 'foo' ],
                      {
                        :show_file_names   => true,
                        :expr              => RegexpExpression.new(%r{foo}, 0),
                      })
    end
  end

  def test_label
    %w{ testing 123 any*char\/acters }.each do |label|
      [
       [ '--label=' + label ],
       [ '--label',   label ]
      ].each do |opt|
        run_option_test(opt | %w{ foo },
                        {
                          :label             => label,
                          :expr              => RegexpExpression.new(%r{foo}, 0),
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
        run_option_test(args | %w{ foo },
                        { 
                          :match_limit     => num.to_i,
                          :expr            => RegexpExpression.new(%r{foo}, 0),
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
          run_option_test(args | %w{ foo },
                          { 
                            :with_basename   => Regexp.new(pat),
                            :expr            => RegexpExpression.new(%r{foo}, 0),
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
          run_option_test(args | %w{ foo },
                          { 
                            :without_basename => Regexp.new(pat),
                            :expr             => RegexpExpression.new(%r{foo}, 0),
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
          run_option_test(args | %w{ foo },
                          { 
                            :with_fullname   => Regexp.new(pat),
                            :expr            => RegexpExpression.new(%r{foo}, 0),
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
          run_option_test(args | %w{ foo },
                          { 
                            :without_fullname => Regexp.new(pat),
                            :expr             => RegexpExpression.new(%r{foo}, 0),
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
        run_option_test(opt | %w{ foo },
                        {
                          :range            => Glark::Range.new(rg, nil),
                          :expr             => RegexpExpression.new(%r{foo}, 0),
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
        run_option_test(opt | %w{ foo },
                        {
                          :range            => Glark::Range.new(nil, rg),
                          :expr             => RegexpExpression.new(%r{foo}, 0),
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
        run_option_test(opt | %w{ foo },
                        {
                          :range            => Glark::Range.new(from, to),
                          :expr             => RegexpExpression.new(%r{foo}, 0),
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
        run_option_test(opt | %w{ foo },
                        {
                          :binary_files     => val,
                          :expr             => RegexpExpression.new(%r{foo}, 0),
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
        run_option_test(opt | %w{ foo },
                        {
                          :size_limit       => val,
                          :expr             => RegexpExpression.new(%r{foo}, 0),
                        })
      end
    end
  end

  def test_text_highlight
    [ 'red', 'blue', 'cyan', 'bold blue', 'blue bold' ].each do |color|
      [ 
       [ '--text-color="' + color + '"' ],
       [ '--text-color=' + color ],
      ].each do |opt|
        run_option_test(opt | [ 'foo' ],
                        {
                          :text_highlights  => [ Text::ANSIHighlighter.make(color) ],
                          :expr             => RegexpExpression.new(%r{foo}, 0),
                        })
      end
    end
  end
  
  def test_file_color
    [ 'red', 'blue', 'cyan', 'bold blue', 'blue bold' ].each do |color|
      [ 
       [ '--file-color',    color ],
       [ '--file-color="' + color + '"' ],
       [ '--file-color='  + color ],
      ].each do |opt|
        run_option_test(opt | [ 'foo' ],
                        {
                          :file_highlight   => Text::ANSIHighlighter.make(color),
                          :expr             => RegexpExpression.new(%r{foo}, 0),
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
      refo = RegexpExpression.new Regexp.new(re), 0
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
        run_option_test(opt,
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

    re0, re1 = pats.collect { |pat| RegexpExpression.new(Regexp.new(pat), 0) }
    
    orexpr = InclusiveOrExpression.new re0, re1
    
    [ 
     [ '-o', *pats ],
    ].each do |opt|
      run_option_test(opt,
                      {
                        :expr             => orexpr,
                      })
    end
  end
  
  def test_and_expression
    pats = %w{ foo bar }

    re0, re1 = pats.collect { |pat| RegexpExpression.new(Regexp.new(pat), 0) }
    
    exp = AndExpression.new 0, re0, re1
    
    [ 
     [ '-a', 0, *pats ],
    ].each do |opt|
      run_option_test(opt,
                      {
                        :expr => exp,
                      })
    end
  end
  
end

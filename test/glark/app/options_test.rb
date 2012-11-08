#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pathname'
require 'tempfile'
require 'tc'
require 'glark/app/options'

module Glark
  class OptionsTestCase < TestCase
    def setup
      # ignore what they have in ENV[HOME]    
      ENV['HOME'] = '/this/should/not/exist'
    end

    def assert_method_values opts, exp
      return unless exp
      exp.each do |name, expval|
        val = opts.method(name).call
        assert_equal expval, val
      end
    end

    def run_test args, expected, &blk
      gopt = Glark::AppOptions.new
      gopt.run args
      outputopts = gopt.output_options
      outputopts.set_files Array.new

      assert_method_values gopt, expected[:app]
      assert_method_values gopt.match_options, expected[:match]
      assert_method_values gopt.colors, expected[:colors]
      assert_method_values gopt.output_options, expected[:output]
      assert_method_values gopt.info_options, expected[:info]
      assert_method_values gopt.input_options, expected[:input]
      
      blk.call(gopt) if blk
    end

    def test_default_values
      run_test(%w{ foo file1 file2 }, 
               :app => { :expr => RegexpExpression.new(%r{foo}, 0) })
    end

    def test_extract_match
      run_test(%w{ --extract-matches foo file1 file2 },
               :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
               :match => { :extract_matches => true })
    end

    def test_extract_match_incomplete
      str = '--extract-matches'
      (5 ... str.length - 1).each do |idx|
        tag = str[0 .. idx]
        run_test([ tag ] + %w{ foo file1 file2 },
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :match => { :extract_matches => true })
      end
    end

    def test_record_separator
      %w{ -0 -00 -000 }.each do |arg|
        $/ = "\n"
        run_test([ arg ] + %w{ foo file1 file2 },
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) }) do |gopt|
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
        run_test(args + %w{ foo },
                 :app => { 
                   :expr => RegexpExpression.new(%r{foo}i, 0),
                 },
                 :match => { :ignorecase => true },
                 :output => { :file_names_only => true },
                 :input => { :directory => "recurse" })
      end
    end

    def test_context_default
      %w{ -C --context }.each do |ctx|
        args = [ ctx, 'foo' ]
        run_test(args,
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :after => 2, :before => 2 }
                 )
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
          run_test(args + %w{ foo },
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :output => { :after => val, :before => val }
                   )
        end
      end
      
      vals = (1 .. 10).to_a  | (1 .. 16).collect { |x| 2 ** x }
      vals.each do |val|
        args = [ '-' + val.to_s, 'foo' ]
        run_test(args,
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :after => val, :before => val }
                 )
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
          run_test(args + %w{ foo },
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :output => { :after => val })
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
          run_test(args + %w{ foo },
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :output => { :before => val })
        end
      end
    end

    def test_highlight
      %w{ -u --highlight }.each do |hlopt|
        run_test([ hlopt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :color => { :text_color_style => "multi" })
      end

      %w{ multi }.each do |val|
        [
         [ '--highlight=' + val ],
         [ '--highlight',   val ],
        ].each do |opt|
          run_test(opt + [ 'foo' ],
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :color => { :text_color_style => val })
        end
      end

      singlecolor = Text::ANSIHighlighter.make(Text::Highlighter::DEFAULT_COLORS[0])

      %w{ single }.each do |val|
        [
         [ '--highlight=' + val ],
         [ '--highlight',   val ],
        ].each do |opt|
          run_test(opt + [ 'foo' ],
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :match => { :text_highlights => [ singlecolor ] },
                   :color => { :text_color_style => val })
        end
      end

      %w{ none }.each do |val|
        run_test([ '--highlight=' + val, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :match => { :text_highlights => [] },
                 :color => { :text_color_style => nil })
      end
    end

    def test_no_highlight
      %w{ -U --no-highlight }.each do |hlopt|
        run_test([ hlopt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :match => { :text_highlights => [] },
                 :color => { :text_color_style => nil })
      end
    end
    
    def test_verbose
      if origverb = Log.verbose

        %w{ --verbose }.each do |vtag|
          [ nil, 1, 2, 3, 4 ].each do |num|
            vopt = vtag
            if num
              vopt += "=" + num.to_s
            end
            Log.verbose = nil
            run_test([ vopt, 'foo' ],
                     :app => { 
                       :expr => RegexpExpression.new(%r{foo}, 0),
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
        run_test([ vopt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :invert_match => true })
      end
    end
    
    def test_ignore_case
      %w{ -i --ignore-case }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}i, 0) },
                 :match => { :ignorecase => true })
      end
    end
    
    def test_filter
      %w{ --filter }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :filter => true })
      end
    end
    
    def test_no_filter
      %w{ --no-filter --nofilter }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :filter => false })
      end
    end
    
    def test_output_type
      %w{ -g --grep }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :match => { :text_highlights => [] },
                 :output => { :after => 0, :before => 0, :show_line_numbers => false, :style => "grep" },
                 :colors => { :text_color_style => false })
      end
    end
    
    def test_line_number
      %w{ -n --line-number }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :show_line_numbers => true })
      end
    end

    def test_no_line_number
      %w{ -N --no-line-number }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :show_line_numbers => false })
      end
    end

    def test_explain
      %w{ --explain }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :info => { :explain => true })
      end
    end

    def test_quiet
      %w{ -q -s --quiet --messages }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) }) do |opts|
          assert Log.quiet
        end
      end
    end

    def test_no_quiet
      %w{ -Q -S --no-quiet --no-messages }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) }) do |opts|
          assert !Log.quiet
        end
      end
    end

    def test_whole_words
      %w{ -w --word }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{\bfoo\b}, 0) },
                 :match => { :whole_words => true })
      end
    end

    def test_whole_lines
      %w{ -x --line-regexp }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{^foo$}, 0) },
                 :match => { :whole_lines => true })
      end
    end

    def test_files_with_matches
      %w{ -l --files-with-matches }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :invert_match => false, :file_names_only => true })
      end
    end

    def test_files_without_matches
      %w{ -L --files-without-match }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :invert_match => true, :file_names_only => true })
      end
    end

    def test_count
      %w{ -c --count }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :count => true })
      end
    end

    def test_write_null
      %w{ -Z --null }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :write_null => true })
      end
    end

    def test_exclude_matching
      %w{ -M --exclude-matching }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :input => { :exclude_matching => true })
      end
    end

    def test_directory_short
      %w{ read recurse skip }.each do |opt|
        run_test([ '-d', opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :input => { :directory => opt })
      end
    end
    
    def test_recurse
      %w{ -r --recurse }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :input => { :directory => 'recurse' })
      end
    end

    def test_extract_matches
      %w{ -y --extract-matches }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :match => { :extract_matches => true })
      end
    end

    def test_no_split_as_path
      %w{ --no-split-as-path }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :input => { :split_as_path => false })
      end
    end

    def run_split_as_path_test exp, args
      args.each do |val|
        [ 
         [ '--split-as-path',   val ],
         [ '--split-as-path=' + val ]
        ].each do |opt|
          run_test(opt + [ 'foo' ],
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :input => { :split_as_path => exp })
        end
      end
    end

    def test_split_as_path
      run_test([ '--split-as-path', 'foo' ],
               :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
               :input => { :split_as_path => true })
      
      run_split_as_path_test(true,  %w{ true  on  yes })
      run_split_as_path_test(false, %w{ false off no  })
    end

    def test_directory_long
      %w{ read recurse skip }.each do |val|
        [
         [ '--directories=' + val ],
         [ '--directories',   val ]
        ].each do |args|
          run_test(args + %w{ foo },
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :input => { :directory => val })
        end
      end
    end

    def test_no_show_file_names
      %w{ -h --no-filename }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :show_file_names => false })
      end
    end

    def test_show_file_names
      %w{ -H --with-filename }.each do |opt|
        run_test([ opt, 'foo' ],
                 :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                 :output => { :show_file_names => true })
      end
    end

    def test_label
      %w{ testing 123 any*char\/acters }.each do |label|
        [
         [ '--label=' + label ],
         [ '--label',   label ]
        ].each do |opt|
          run_test(opt + %w{ foo },
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :output => { :label => label })
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
          run_test(args + %w{ foo },
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :output => { :match_limit => num.to_i })
        end
      end
    end

    def test_with_basename
      %w{ abc123 \w+\S* }.each do |pat|
        %w{ --with-basename --basename --with-name --name --match-name }.each do |tag|
          [
           [ tag, pat ],
           [ tag + '=' + pat ]
          ].each do |args|
            run_test(args + %w{ foo },
                     :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                     :input => { :match_name => Regexp.new(pat) })
          end
        end
      end
    end

    def test_without_basename
      %w{ abc123 \w+\S* }.each do |pat|
        %w{ --without-basename --without-name --not-name }.each do |tag|
          [
           [ tag, pat ],
           [ tag + '=' + pat ]
          ].each do |args|
            run_test(args + %w{ foo },
                     :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                     :input => { :nomatch_name => Regexp.new(pat) })
          end
        end
      end
    end

    def test_match_path
      %w{ abc123 \w+\S* }.each do |pat|
        %w{ --with-fullname --fullname --with-path --path --match-path }.each do |tag|
          [
           [ tag, pat ],
           [ tag + '=' + pat ]
          ].each do |args|
            run_test(args + %w{ foo },
                     :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                     :input => { :match_path => Regexp.new(pat) })
          end
        end
      end
    end

    def test_nomatch_path
      %w{ abc123 \w+\S* }.each do |pat|
        %w{ --without-fullname --without-path --not-path }.each do |tag|
          [
           [ tag, pat ],
           [ tag + '=' + pat ]
          ].each do |args|
            run_test(args + %w{ foo },
                     :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                     :input => { :nomatch_path => Regexp.new(pat) })
          end
        end
      end
    end

    def run_range_test expfrom, expto, args
      run_test(args + %w{ foo },
               :app => { :range => Glark::Range.new(expfrom, expto), :expr => RegexpExpression.new(%r{foo}, 0) })
    end

    def test_range_start
      %w{ 5 5% 10 90% }.each do |rg|
        [
         [ '--after=' + rg ],
         [ '--after',   rg ]
        ].each do |opt|
          run_range_test rg, nil, opt
        end
      end
    end

    def test_range_end
      %w{ 5 5% 10 90% }.each do |rg|
        [
         [ '--before=' + rg ],
         [ '--before',   rg ],
        ].each do |opt|
          run_range_test nil, rg, opt
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
          run_range_test from, to, opt
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
          run_test(opt + %w{ foo },
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :input => { :binary_files => val })
        end
      end
    end

    def test_size_limit
      [ 0, 1, 10, 10000, 100000 ].each do |val|
        [
         [ '--size-limit=' + val.to_s ],
         [ '--size-limit',   val.to_s ],
        ].each do |opt|
          run_test(opt + %w{ foo },
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :input => { :size_limit => val })
        end
      end
    end

    def test_text_highlight
      [ 'red', 'blue', 'cyan', 'bold blue', 'blue bold' ].each do |color|
        [ 
         [ '--text-color="' + color + '"' ],
         [ '--text-color=' + color ],
        ].each do |opt|
          run_test(opt + [ 'foo' ],
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :match => { :text_highlights => [ Text::ANSIHighlighter.make(color) ] })
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
          run_test(opt + [ 'foo' ],
                   :app => { :expr => RegexpExpression.new(%r{foo}, 0) },
                   :colors => { :file_highlight => Text::ANSIHighlighter.make(color) })
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
          run_test(opt,
                   :app => { :expr => orexpr })
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
        run_test(opt,
                 :app => { :expr => orexpr })
      end
    end
    
    def test_and_expression
      pats = %w{ foo bar }

      re0, re1 = pats.collect { |pat| RegexpExpression.new(Regexp.new(pat), 0) }
      
      exp = AndExpression.new 0, re0, re1
      
      [ 
       [ '-a', 0, *pats ],
      ].each do |opt|
        run_test(opt,
                 :app => { :expr => exp })
      end
    end
  end
end

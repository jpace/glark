#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/tc'

class Glark::BaseNameFilterTest < Glark::TestCase
  def run_bnf_test expmatch, pattern, fname
    bnf = BaseNameFilter.new pattern
    assert_equal expmatch, bnf.match?(Pathname.new fname), "fname: #{fname}"
  end

  def test_match_string_to_string
    run_bnf_test true, '.svn', '.svn'
  end

  def test_no_match_string_with_substring
    run_bnf_test false, '.svn', '.'
  end
end

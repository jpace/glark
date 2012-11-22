#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/tc'
require 'glark/input/filter/filter_list'

class Glark::FilterListTest < Glark::TestCase
  def run_bnf_test expmatch, pattern, fname
    bnf = BaseNameFilter.new pattern
    assert_equal expmatch, bnf.match?(Pathname.new fname), "fname: #{fname}"
  end

  def test_empty
    fl = Glark::FilterList.new
    assert fl.empty?
  end

  def test_not_empty
    fl = Glark::FilterList.new
    fl << Filter.new
    assert !fl.empty?
  end

  def test_match
    fl = Glark::FilterList.new
    fl << BaseNameFilter.new('.svn')
    assert fl.match?(Pathname.new '/path/to/.svn')
  end

  def test_find_by_class
    fl = Glark::FilterList.new
    bnf = BaseNameFilter.new('.svn')
    fl << bnf
    assert_equal bnf.object_id, fl.find_by_class(BaseNameFilter).object_id
  end

  def test_each
    fl = Glark::FilterList.new
    svnbnf = BaseNameFilter.new('.svn')
    fl << svnbnf
    bldbnf = BaseNameFilter.new('build')
    fl << bldbnf
    filters = [ svnbnf, bldbnf ]
    fl.each_with_index do |filter, idx|
      assert_equal filters[idx].object_id, filter.object_id
    end
  end
end

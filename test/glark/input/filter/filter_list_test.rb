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
    fl.add :name, :positive, Filter.new
    assert !fl.empty?
  end

  def test_match
    fl = Glark::FilterList.new
    fl.add :name, :positive, BaseNameFilter.new('.svn')
    assert fl.match?(:name, :positive, Pathname.new('/path/to/.svn'))
  end

  def test_find_by_class
    fl = Glark::FilterList.new
    bnf = BaseNameFilter.new '.svn'
    fl.add :name, :negative, bnf
    assert_equal bnf.object_id, fl.find_by_class(:name, :negative, BaseNameFilter).object_id
  end

  def test_add
    fl = Glark::FilterList.new
    svnbnf = BaseNameFilter.new '.svn'
    fl.add :name, :negative, svnbnf
    bldbnf = BaseNameFilter.new 'build'
    fl.add :name, :negative, bldbnf

    slf = SizeLimitFilter.new 1000
    fl.add :size, :negative, slf

    extf = ExtFilter.new 'rb'
    fl.add :ext, :positive, extf
  end
end

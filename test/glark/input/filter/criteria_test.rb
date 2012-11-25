#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'
require 'glark/util/io/filter/criteria'
require 'glark/input/filter/filter'

class Glark::CriteriaTestCase < Glark::AppTestCase
  def test_positive_one_match
    crit = Glark::Criteria.new
    crit.add :name, :positive, BaseNameFilter.new('foo.txt')
    
    assert crit.match?(Pathname.new '/path/to/foo.txt')
  end

  def test_positive_one_nomatch
    crit = Glark::Criteria.new
    crit.add :name, :positive, BaseNameFilter.new('foo.txt')
    
    assert !crit.match?(Pathname.new '/path/to/bar.txt')
  end

  def test_negative_one_match
    crit = Glark::Criteria.new
    crit.add :name, :negative, BaseNameFilter.new('foo.txt')
    
    assert !crit.match?(Pathname.new '/path/to/foo.txt')
  end

  def test_negative_one_nomatch
    crit = Glark::Criteria.new
    crit.add :name, :negative, BaseNameFilter.new('foo.txt')
    
    assert crit.match?(Pathname.new '/path/to/bar.txt')
  end

  def test_positive_two_match
    crit = Glark::Criteria.new
    crit.add :name, :positive, BaseNameFilter.new(%r{foo.*})
    crit.add :ext, :positive, ExtFilter.new('txt')
    
    assert crit.match?(Pathname.new '/path/to/foo.txt')
  end

  def test_positive_two_nomatch
    crit = Glark::Criteria.new
    crit.add :name, :positive, BaseNameFilter.new(%r{foo.*})
    crit.add :ext, :positive, ExtFilter.new('rb')
    
    assert crit.match?(Pathname.new '/path/to/foo.rb')
  end

  def test_positive_negative_match
    crit = Glark::Criteria.new
    crit.add :name, :positive, BaseNameFilter.new(%r{foo.*})
    crit.add :ext, :negative, ExtFilter.new('txt')
    
    assert crit.match?(Pathname.new '/path/to/foo.rb')
  end

  def test_positive_negative_nomatch
    crit = Glark::Criteria.new
    crit.add :name, :positive, BaseNameFilter.new(%r{foo.*})
    crit.add :ext, :negative, ExtFilter.new('rb')
    
    assert !crit.match?(Pathname.new '/path/to/foo.rb')
  end

  def test_find_by_class
    fl = Glark::Criteria.new
    bnf = BaseNameFilter.new '.svn'
    fl.add :name, :negative, bnf
    assert_equal bnf.object_id, fl.find_by_class(:name, :negative, BaseNameFilter).object_id
  end

  def test_add
    fl = Glark::Criteria.new
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

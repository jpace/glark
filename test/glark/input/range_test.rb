#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/tc'
require 'glark/input/range'

module Glark
  class RangeTestCase < Glark::TestCase
    def test_ctor
      rg = Glark::Range.new '3', '17'
      assert_equal '3', rg.from
      assert_equal '17', rg.to
    end

    def test_valid_neither    
      rg = Glark::Range.new
      assert rg.validate!
    end

    def test_valid_only_from
      rg = Glark::Range.new '3'
      assert rg.validate!
    end

    def test_valid_only_to
      rg = Glark::Range.new nil, '17'
      assert rg.validate!
    end

    def test_valid_from_number_to_number
      rg = Glark::Range.new '3', '17'
      assert rg.validate!
    end

    def test_valid_from_number_to_pct
      rg = Glark::Range.new '3', '17%'
      assert rg.validate!
    end

    def test_valid_from_pct_to_pct
      rg = Glark::Range.new '3%', '17%'
      assert rg.validate!
    end

    def test_valid_from_pct_to_number
      rg = Glark::Range.new '3%', '17'
      assert rg.validate!
    end

    def test_invalid_from_pct_to_pct
      rg = Glark::Range.new '13%', '3%'
      assert_raises(Glark::RangeError) do
        rg.validate!
      end
    end

    def test_invalid_from_number_to_number
      rg = Glark::Range.new '13', '3'
      assert_raises(Glark::RangeError) do
        rg.validate!
      end
    end

    def test_eq_from_to
      x = Glark::Range.new '5', '17'
      y = Glark::Range.new '5', '17'
      assert_equal y, x
    end

    def test_eq_nil_to
      x = Glark::Range.new nil, '5'
      y = Glark::Range.new nil, '5'
      assert_equal y, x
    end

    def test_eq_from_nil
      x = Glark::Range.new '5', nil
      y = Glark::Range.new '5', nil
      assert_equal y, x
    end
  end
end

require File.join(File.dirname(__FILE__), '../../test_helper')

class HashSmartMergeTest < Test::Unit::TestCase
  
  def test_smart_merge!
    one = { :foo => "123", :bar => "456" }
    two = { :bar => "789", :bat => "012" }
    one.smart_merge!(two)
    expected = { :foo => "123", :bar => ["456", "789"], :bat => "012" }
    assert_equal expected, one
  end
  
  def test_smart_merge_with_nils
    one = { :foo => "123", :bar => nil }
    two = { :bar => "789", :bat => "012" }
    one.smart_merge!(two)
    expected = { :foo => "123", :bar => [nil, "789"], :bat => "012" }
    assert_equal expected, one
  end
  
  def test_smart_merge_with_an_array_value
    one = { :foo => "123", :bar => ["566", "667"] }
    two = { :bar => "789", :bat => "012" }
    one.smart_merge!(two)
    expected = { :foo => "123", :bar => [["566", "667"], "789"], :bat => "012" }
    assert_equal expected, one
  end
  
  def test_smart_merge_three_hashes
    one = { :foo => "123", :bar => "456" }
    two = { :bar => "789", :bat => "012" }
    thr = { :bat => "556", :ant => "667" }
    one.smart_merge!(two)
    one.smart_merge!(thr)
    expected = { :foo => "123", :bar => ["456", "789"], :bat => ["012", "556"], :ant => "667" }
    assert_equal expected, one
  end
  
end
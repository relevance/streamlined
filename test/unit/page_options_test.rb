require File.join(File.dirname(__FILE__), '../test_helper')

class PageOptionsTest < Test::Unit::TestCase
  def test_ascending
    o = PageOptions.new(:sort_order=>'ASC', :sort_column=>"name")
    assert o.ascending?
    assert_equal({:order=>"name ASC"}, o.active_record_order_option)
  end
  
  def test_default_ordering
    o = PageOptions.new(:sort_column=>"name")
    assert o.ascending?
    assert_equal({:order=>"name ASC"}, o.active_record_order_option)
  end
  
  def test_descending
    o = PageOptions.new(:sort_order=>'DESC', :sort_column=>"name")
    assert !o.ascending?
    assert_equal({:order=>"name DESC"}, o.active_record_order_option)
  end
  
  def test_empty_order_option
    o = PageOptions.new
    assert_equal({}, o.active_record_order_option)
  end
  
  def test_sort_column
    o = PageOptions.new
    column = Struct.new(:human_name).new("foo")
    assert_equal false, o.sort_column?(column)
    o.sort_column = "foo"
    assert_equal true, o.sort_column?(column)
  end
end
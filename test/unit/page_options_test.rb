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
  
end
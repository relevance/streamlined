require File.join(File.dirname(__FILE__), '../../../test_helper')

class Streamlined::Context::RequestContextTest < Test::Unit::TestCase
  include Streamlined::Context
  def test_ascending
    o = RequestContext.new(:sort_order=>'ASC', :sort_column=>"name")
    assert o.sort_ascending?
    assert_equal({:order=>"name ASC"}, o.active_record_order_option)
  end
  
  def test_default_ordering
    o = RequestContext.new(:sort_column=>"name")
    assert o.sort_ascending?
    assert_equal({:order=>"name ASC"}, o.active_record_order_option)
  end
  
  def test_descending
    o = RequestContext.new(:sort_order=>'DESC', :sort_column=>"name")
    assert !o.sort_ascending?
    assert_equal({:order=>"name DESC"}, o.active_record_order_option)
  end
  
  def test_empty_order_option
    o = RequestContext.new
    assert_equal({}, o.active_record_order_option)
  end
  
  def test_sort_column
    o = RequestContext.new
    column = Struct.new(:name).new("foo")
    assert_equal false, o.sort_column?(column)
    o.sort_column = "foo"
    assert_equal true, o.sort_column?(column)
  end
end
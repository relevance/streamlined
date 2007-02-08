require File.join(File.dirname(__FILE__), '../test_helper')
require 'streamlined_ui'

class RelevanceModuleHelpersTest < Test::Unit::TestCase
  def setup
    @inst = Relevance::ModuleHelper 
  end
  def test_reader_from_options
    assert_equal("@foo", @inst.reader_from_options("foo"))
    assert_equal("defined?(@foo) ? @foo : []", @inst.reader_from_options("foo", :default=>[]))
  end
end

class StreamlinedUITest < Test::Unit::TestCase
  include FlexMock::TestCase
  
  def setup
    @ui = Streamlined::UI
  end

  def test_popup_items
    assert_equal [], @ui.popup_columns
    assert_equal ["foo"], @ui.popup_columns("foo")
    assert_equal ["foo"], @ui.popup_columns
  end
  
  def test_popup_events_for_item
    
  end
  
  def test_edit_link_column
    assert_equal nil, @ui.edit_link_column
    assert_equal "foo", @ui.edit_link_column("foo")
    assert_equal "foo", @ui.edit_link_column
  end
  
  def test_pagination
    assert_equal true, @ui.pagination
    assert_equal "foo", @ui.pagination("foo")
    assert_equal "foo", @ui.pagination
    assert_equal "bar", @ui.pagination="bar"
    assert_equal "bar", @ui.pagination
    assert_equal false, @ui.pagination=false
    assert_equal false, @ui.pagination
  end
  
  def test_model
    flexstub(@ui).should_receive(:default_model).and_return(Class)
    assert_equal Class, @ui.model
    assert_equal String, @ui.model(:string)
    assert_equal String, @ui.model
    assert_equal Fixnum, @ui.model("Fixnum")
    assert_equal Fixnum, @ui.model
  end
  
  def test_calculated_columns
    assert_equal [1,2], [1,2]
    assert_equal [], @ui.calculated_columns
    assert_equal [Streamlined::Column.new("foo")], @ui.calculated_columns("foo")
  end
  
end

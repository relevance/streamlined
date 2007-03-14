require File.join(File.dirname(__FILE__), '../../test_helper')
require 'streamlined/ui'

class RelevanceModuleHelpersTest < Test::Unit::TestCase
  def setup
    @inst = Relevance::ModuleHelper 
  end
  def test_reader_from_options
    assert_equal("@foo", @inst.reader_from_options("foo"))
    assert_equal("defined?(@foo) ? @foo : []", @inst.reader_from_options("foo", :default=>[]))
  end
end

class Streamlined::UITest < Test::Unit::TestCase
  include FlexMock::TestCase
  
  def setup
    @ui = Class.new(Streamlined::UI)
  end
  
  def test_declarative_setting_inheritance
    @ui.table_row_buttons = :some_value
    subclass = Class.new(@ui)
    assert_equal :some_value, subclass.table_row_buttons
    @ui.table_row_buttons = :another_value
    assert_equal :some_value, subclass.table_row_buttons
    assert_equal :another_value, @ui.table_row_buttons
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
  
  # def test_column_header
  #   assert_equal '', @ui.column_header(nil)
  #   column = flexmock('column')
  #   column.should_receive(:name).and_return('ColumnName')
  #   column.should_receive(:human_name).and_return('Column name')
  #   
  #   assert_equal("Column name", @ui.column_header(column))
  #   
  #   @ui.column_headers(:headers => {'NoSuchColumn' => 'no such column'})
  #   
  #   assert_equal("Column name", @ui.column_header(column))
  #   
  #   column = flexmock('column')
  #   column.should_receive(:name).and_return('ColumnName')
  #   @ui.column_headers(:headers => {:ColumnName => 'a custom name'})
  #   assert_equal("a custom name", @ui.column_header(column))
  #   
  # end
    
end

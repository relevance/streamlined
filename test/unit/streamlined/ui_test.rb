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
  
  def setup
    @ui = Class.new(Streamlined::UI)
  end
  
  class Test; end
  class TestUI; end
  class TestWithout; end
  
  def test_get_ui
    assert_equal TestUI, Streamlined::UI.get_ui(Test.name)
    assert_equal Streamlined::UI::Generic, Streamlined::UI.get_ui(TestWithout.name)
  end
  
  def test_declarative_setting_inheritance
    @ui.table_row_buttons = :some_value
    @ui.quick_delete_button = :some_value    
    subclass = Class.new(@ui)
    assert_equal :some_value, subclass.table_row_buttons
    assert_equal :some_value, subclass.quick_delete_button
    @ui.table_row_buttons = :another_value
    @ui.quick_delete_button = :another_value    
    assert_equal :some_value, subclass.table_row_buttons
    assert_equal :another_value, @ui.table_row_buttons
    assert_equal :some_value, subclass.quick_delete_button
    assert_equal :another_value, @ui.quick_delete_button
  end
  
  def test_read_only
    assert_equal nil, @ui.read_only
    assert_equal true, @ui.read_only(true)
    assert_equal true, @ui.read_only
  end
  
  def test_pagination
    assert_equal true, @ui.pagination
    assert_equal "foo", @ui.pagination("foo")
    assert_equal "foo", @ui.pagination
    assert_equal "bar", @ui.pagination="bar"
    assert_equal "bar", @ui.pagination
    assert_false @ui.pagination=false
    assert_false @ui.pagination
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

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
  class TestModel; end
  def setup
    @ui = Streamlined::UI.new(TestModel)
  end
  
  def test_style_class_for_with_empty_style_classes_hash
    assert_equal({}, @ui.style_classes)
    assert_nil @ui.style_class_for(:list, :cell, nil)
  end
  
  def test_style_class_for_with_string
    flexmock(@ui).should_receive(:style_classes).and_return(:list => { :cell => "color: red" })
    assert_equal "color: red", @ui.style_class_for(:list, :cell, nil)
    assert_nil @ui.style_class_for(:list, :row, nil)
  end
  
  def test_style_class_for_with_proc
    flexmock(@ui).should_receive(:style_classes).and_return(:list => { :cell => Proc.new { |i| i.style }})
    item = flexmock(:style => "color: black")
    assert_equal "color: black", @ui.style_class_for(:list, :cell, item)
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
    assert_equal TestModel, @ui.model
    # TODO: where are these model methods used?
    # assert_equal String, @ui.model(:string)
    # assert_equal String, @ui.model
    # assert_equal Fixnum, @ui.model("Fixnum")
    # assert_equal Fixnum, @ui.model
  end
  
  def test_quick_button_defaults
    assert_equal true, @ui.quick_delete_button
    assert_equal true, @ui.quick_edit_button
    assert_equal true, @ui.quick_new_button
  end
  
  def test_new_submit_button
    assert_equal true, @ui.new_submit_button[:ajax]
    assert_equal false, @ui.new_submit_button({:ajax => false})[:ajax]
    assert_equal false, @ui.new_submit_button[:ajax]
  end
  
  def test_edit_submit_button
    assert_equal true, @ui.edit_submit_button[:ajax]
    assert_equal false, @ui.edit_submit_button({:ajax => false})[:ajax]
    assert_equal false, @ui.edit_submit_button[:ajax]
  end
  
  def test_header_and_footer_partials_have_defaults
    assert_equal({}, @ui.header_partials)
    assert_equal({}, @ui.after_header_partials)
    assert_equal({}, @ui.footer_partials)
  end
  
  def test_custom_columns_group
    first_name = flexmock(:name => :first_name)
    last_name = flexmock(:name => :last_name)
    flexmock(TestModel).should_receive(:columns).and_return([first_name, last_name]).once
    @ui.custom_columns_group(:group, :first_name, :last_name)
    assert_equal 2, @ui.custom_columns_group(:group).size
  end

  def test_quick_add_columns_with_args
    flexmock(@ui).should_receive(:convert_args_to_columns).and_return(:return_val).once
    assert_equal :return_val, @ui.quick_add_columns(:anything)
  end

  def test_quick_add_columns_with_no_args
    addition = flexmock("addition")
    addition.should_receive(:is_a?).and_return(true).once
    flexmock(@ui).should_receive(:user_columns).and_return([:anything, addition]).once
    assert_equal [:anything], @ui.quick_add_columns
  end
end

require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/addition'

class Streamlined::Column::ActiveRecordTest < Test::Unit::TestCase
  include Streamlined::Column
  
  ENUM = %w{ A B C }
  
  def setup
    ar_column = flexmock(:name => 'column')
    @ar = ActiveRecord.new(ar_column)
  end
  
  def test_initialize
    ar = ActiveRecord.new(:foo)
    assert_equal :foo, ar.ar_column
    assert_nil ar.human_name
  end
  
  def test_initialize_with_human_name
    ar = ActiveRecord.new(flexmock(:human_name => 'Foo'))
    assert_equal 'Foo', ar.human_name
  end
  
  def test_names_delegate_to_ar_column
    ar = ActiveRecord.new(ar_column('foo_bar', 'Foo bar'))
    assert_equal 'foo_bar', ar.name
    assert_equal 'Foo bar', ar.human_name
  end
  
  def test_human_name_can_be_set_manually
    ar = ActiveRecord.new(ar_column('foo_bar', 'Foo bar'))
    ar.human_name = 'Bar Foo'
    assert_equal 'Bar Foo', ar.human_name
  end
  
  def test_enumeration_can_be_set
    assert_nil @ar.enumeration
    @ar.enumeration = ENUM
    assert_equal ENUM, @ar.enumeration
  end
  
  def test_equal
    a1 = ActiveRecord.new(:foo)  
    a2 = ActiveRecord.new(:foo)
    a3 = ActiveRecord.new(:bar)
    a4 = ActiveRecord.new(nil)
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  def test_equal_with_human_name
    (a1 = ActiveRecord.new(:foo)).human_name = 'Foo'
    (a2 = ActiveRecord.new(:foo)).human_name = 'Foo'
    (a3 = ActiveRecord.new(:foo)).human_name = 'Bar'
    (a4 = ActiveRecord.new(:foo)).human_name = nil
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  def test_equal_with_enumeration
    (a1 = ActiveRecord.new(:foo)).enumeration = ['Foo']
    (a2 = ActiveRecord.new(:foo)).enumeration = ['Foo']
    (a3 = ActiveRecord.new(:foo)).enumeration = ['Bar']
    (a4 = ActiveRecord.new(:foo)).human_name = nil
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  def test_edit_view
    assert @ar.edit_view.is_a?(Streamlined::View::EditViews::EnumerableSelect)
  end
  
  def test_show_view
    assert @ar.show_view.is_a?(Streamlined::View::ShowViews::Enumerable)
  end
  
  def test_render_td_edit_with_enumeration
    @ar.enumeration = %w{ foo bar }
    flexmock(@ar) do |mock|
      mock.should_receive(:render_enumeration_select).with('view', 'item').and_return('select').once
    end
    assert_equal 'select', @ar.render_td_edit('view', 'item')
  end
  
  def test_render_td_as_edit
    view = flexmock(:model_underscore => 'model', :crud_context => :edit)
    view.should_receive(:input).with('model', 'column').and_return('input').once
    assert_equal 'input', @ar.render_td(view, nil)
  end
  
  def test_render_td_as_list
    view = flexmock(:crud_context => :list)
    item = flexmock(:column => 'value', :id => 123)
    assert_equal 'value', @ar.render_td(view, item)
  end
  
  def test_render_td_with_enumeration
    @ar.enumeration = ['foo', 'bar']
    view = flexmock(:render => 'render', :controller_name => 'controller', :link_to_function => 'link', :crud_context => :list)
    item = flexmock(:id => 123)
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>link"
    assert_equal expected, @ar.render_td(view, item)
  end
  
  def ar_column(name, human_name)
    flexmock(:name => name, :human_name => human_name)
  end
end
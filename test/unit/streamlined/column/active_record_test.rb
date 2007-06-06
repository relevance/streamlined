require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/addition'

class Streamlined::Column::ActiveRecordTest < Test::Unit::TestCase
  include Streamlined::Column
  
  def setup
    ar_column = flexmock(:name => 'column')
    model = flexmock(:name => 'model')
    @ar = ActiveRecord.new(ar_column, model)
  end
  
  def test_initialize
    ar = ActiveRecord.new(:foo, nil)
    assert_equal :foo, ar.ar_column
    assert_nil ar.human_name
  end
  
  def test_initialize_with_human_name
    ar = ActiveRecord.new(flexmock(:human_name => 'Foo'), nil)
    assert_equal 'Foo', ar.human_name
  end
  
  def test_names_delegate_to_ar_column
    ar = ActiveRecord.new(ar_column('foo_bar', 'Foo bar'), nil)
    assert_equal 'foo_bar', ar.name
    assert_equal 'Foo bar', ar.human_name
  end
  
  def test_human_name_can_be_set_manually
    ar = ActiveRecord.new(ar_column('foo_bar', 'Foo bar'), nil)
    ar.human_name = 'Bar Foo'
    assert_equal 'Bar Foo', ar.human_name
  end
  
  def test_enumeration_can_be_set
    assert_nil @ar.enumeration
    @ar.enumeration = %w{ A B C }
    assert_equal %w{ A B C }, @ar.enumeration
  end
  
  def test_equal
    a1 = ActiveRecord.new(:foo, nil)
    a2 = ActiveRecord.new(:foo, nil)
    a3 = ActiveRecord.new(:bar, nil)
    a4 = ActiveRecord.new(nil, nil)
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  def test_equal_with_human_name
    (a1 = ActiveRecord.new(:foo, nil)).human_name = 'Foo'
    (a2 = ActiveRecord.new(:foo, nil)).human_name = 'Foo'
    (a3 = ActiveRecord.new(:foo, nil)).human_name = 'Bar'
    (a4 = ActiveRecord.new(:foo, nil)).human_name = nil
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  def test_equal_with_enumeration
    (a1 = ActiveRecord.new(:foo, nil)).enumeration = ['Foo']
    (a2 = ActiveRecord.new(:foo, nil)).enumeration = ['Foo']
    (a3 = ActiveRecord.new(:foo, nil)).enumeration = ['Bar']
    (a4 = ActiveRecord.new(:foo, nil)).human_name = nil
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
  
  def test_render_td_edit
    (view = flexmock).should_receive(:input).with('model', 'column').once
    @ar.render_td_edit(view, 'item')
  end
  
  def test_render_td_edit_with_enumeration
    @ar.enumeration = %w{ A B C }
    flexmock(@ar).should_receive(:render_enumeration_select).with('view', 'item').and_return('select').once
    assert_equal 'select', @ar.render_td_edit('view', 'item')
  end
  
  def test_render_td_edit_with_checkbox
    @ar.check_box = true
    (view = flexmock).should_receive(:check_box).with('model', 'column').once
    @ar.render_td_edit(view, 'item')
  end
  
  def test_render_td_with_wrapper
    @ar.wrapper = Proc.new { |c| "<<<#{c}>>>" }
    (view = flexmock).should_receive(:input).with('model', 'column').and_return('result').once
    assert_equal '<<<result>>>', @ar.render_td_edit(view, 'item')
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
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @view.should_receive(:crud_context).and_return(:list).once
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>link"
    assert_equal expected, @ar.render_td(@view, @item)
  end
  
  def test_render_td_list_with_enumeration_and_create_only_true
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @ar.edit_in_list = false
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>"
    assert_equal expected, @ar.render_td_list(@view, @item)
  end
  
  def test_render_td_list_with_enumeration_and_read_only_true
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @ar.read_only = true
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>"
    assert_equal expected, @ar.render_td_list(@view, @item)
  end
  
  def test_render_td_list_with_enumeration_and_edit_in_list_false
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @ar.read_only = true
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>"
    assert_equal expected, @ar.render_td_list(@view, @item)
  end
  
  def test_render_enumeration_select
    setup_mocks
    @ar.enumeration = %w{ A B C }
    select_choices_should_be [['Unassigned', nil], ['A', 'A'], ['B', 'B'], ['C', 'C']]
    @ar.render_enumeration_select(@view, @item)
  end
  
  def test_render_enumeration_select_with_hash
    setup_mocks
    @ar.enumeration = { 'A' => 1, 'B' => 2, 'C' => 3 }
    select_choices_should_be [['Unassigned', nil], ['A', 1], ['B', 2], ['C', 3]]
    @ar.render_enumeration_select(@view, @item)
  end
  
  def test_render_enumeration_select_with_2d_array
    setup_mocks
    @ar.enumeration = [['A', 1], ['B', 2], ['C', 3]]
    select_choices_should_be [['Unassigned', nil], ['A', 1], ['B', 2], ['C', 3]]
    @ar.render_enumeration_select(@view, @item)
  end
  
  def test_render_enumeration_select_with_custom_unassigned_value
    setup_mocks
    @ar.enumeration = []
    @ar.unassigned_value = 'none'
    select_choices_should_be [['none', nil]]
    @ar.render_enumeration_select(@view, @item)
  end
  
private
  def ar_column(name, human_name)
    flexmock(:name => name, :human_name => human_name)
  end
  
  def setup_mocks
    @view = flexmock(:render => 'render', :controller_name => 'controller_name', :link_to_function => 'link')
    @item = flexmock(:id => 123)
  end
  
  def select_choices_should_be(choices)
    @view.should_receive(:select).with('model', 'column', choices).once
  end
end

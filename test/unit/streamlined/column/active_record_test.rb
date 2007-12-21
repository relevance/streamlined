require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/addition'


describe "Streamlined::Column::ActiveRecord" do
  include Streamlined::Column
  
  def setup
    ar_column = flexmock(:name => 'column')
    model = flexmock(:name => 'model')
    @class_under_test = Streamlined::Column::ActiveRecord
    @ar = @class_under_test.new(ar_column, model)
  end
  
  it "initialize" do
    ar = @class_under_test.new(:foo, nil)
    assert_equal :foo, ar.ar_column
    assert_nil ar.human_name
  end
  
  it "initialize with human name" do
    ar = @class_under_test.new(flexmock(:human_name => 'Foo'), nil)
    assert_equal 'Foo', ar.human_name
  end
  
  it "active record?" do
    assert @class_under_test.new(nil, nil).active_record?
  end
  
  it "table name" do
    ar = @class_under_test.new(nil, flexmock(:table_name => 'Foo'))
    assert_equal 'Foo', ar.table_name
  end
  
  it "filterable defaults to true" do
    assert @class_under_test.new(:foo, nil).filterable
  end
  
  it "names delegate to ar column" do
    ar = @class_under_test.new(ar_column('foo_bar', 'Foo bar'), nil)
    assert_equal 'foo_bar', ar.name
    assert_equal 'Foo Bar', ar.human_name
  end
  
  it "human name can be set manually" do
    ar = @class_under_test.new(ar_column('foo_bar', 'Foo bar'), nil)
    ar.human_name = 'Bar Foo'
    assert_equal 'Bar Foo', ar.human_name
  end
  
  it "enumeration can be set" do
    assert_nil @ar.enumeration
    @ar.enumeration = %w{ A B C }
    assert_equal %w{ A B C }, @ar.enumeration
  end
  
  it "equal" do
    a1 = @class_under_test.new(:foo, nil)
    a2 = @class_under_test.new(:foo, nil)
    a3 = @class_under_test.new(:bar, nil)
    a4 = @class_under_test.new(nil, nil)
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  it "equal with human name" do
    (a1 = @class_under_test.new(:foo, nil)).human_name = 'Foo'
    (a2 = @class_under_test.new(:foo, nil)).human_name = 'Foo'
    (a3 = @class_under_test.new(:foo, nil)).human_name = 'Bar'
    (a4 = @class_under_test.new(:foo, nil)).human_name = nil
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  it "equal with enumeration" do
    (a1 = @class_under_test.new(:foo, nil)).enumeration = ['Foo']
    (a2 = @class_under_test.new(:foo, nil)).enumeration = ['Foo']
    (a3 = @class_under_test.new(:foo, nil)).enumeration = ['Bar']
    (a4 = @class_under_test.new(:foo, nil)).human_name = nil
    assert_equal a1, a2
    assert_not_equal a1, a3
    assert_not_equal a4, a1
  end
  
  it "edit view" do
    assert @ar.edit_view.is_a?(Streamlined::View::EditViews::EnumerableSelect)
  end
  
  it "render td edit" do
    (view = flexmock).should_receive(:input).with('model', 'column', {}).once
    @ar.render_td_edit(view, 'item')
  end
  
  it "render td edit with enumeration" do
    @ar.enumeration = %w{ A B C }
    flexmock(@ar).should_receive(:render_enumeration_select).with('view', 'item').and_return('select').once
    assert_equal 'select', @ar.render_td_edit('view', 'item')
  end
  
  it "render td edit with checkbox" do
    @ar.check_box = true
    (view = flexmock).should_receive(:check_box).with('model', 'column', {}).once
    @ar.render_td_edit(view, 'item')
  end
  
  it "render td edit with wrapper" do
    @ar.wrapper = Proc.new { |c| "<<<#{c}>>>" }
    (view = flexmock).should_receive(:input).with('model', 'column', {}).and_return('result').once
    assert_equal '<<<result>>>', @ar.render_td_edit(view, 'item')
  end
  
  it "render td edit with html options" do
    @ar.html_options = { :class => 'foo_class' }
    (view = flexmock).should_receive(:input).with('model', 'column', { :class => 'foo_class' }).and_return('result').once
    assert_equal 'result', @ar.render_td_edit(view, 'item')
  end
  
  it "render td as edit" do
    view = flexmock(:model_underscore => 'model', :crud_context => :edit)
    view.should_receive(:input).with('model', 'column', {}).and_return('input').once
    assert_equal 'input', @ar.render_td(view, nil)
  end
  
  it "render td as list" do
    view = flexmock(:crud_context => :list)
    item = flexmock(:column => 'value', :id => 123)
    assert_equal 'value', @ar.render_td(view, item)
  end
  
  it "render td show with enumeration and blank value" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    item = flexmock(:column => nil)
    assert_equal "Unassigned", @ar.render_td_show(@view, item)
  end
  
  it "render td with enumeration" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @view.should_receive(:crud_context).and_return(:list).once
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>link"
    assert_equal expected, @ar.render_td(@view, @item)
  end
  
  it "render td list with enumeration and link" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @ar.link_to = { :action => "show" }
    @ar.edit_in_list = false
    flexmock(@view).should_receive(:wrap_with_link).and_return("render_with_link").once
    assert_equal "<div id=\"EnumerableSelect::column::123::\">render_with_link</div>", @ar.render_td_list(@view, @item)
  end
  
  it "render td list with enumeration and create only true" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @ar.edit_in_list = false
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>"
    assert_equal expected, @ar.render_td_list(@view, @item)
  end
  
  it "render td list with enumeration and read only true" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @ar.read_only = true
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>"
    assert_equal expected, @ar.render_td_list(@view, @item)
  end
  
  it "render td list with enumeration and edit in list false" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    @ar.read_only = true
    expected = "<div id=\"EnumerableSelect::column::123::\">render</div>"
    assert_equal expected, @ar.render_td_list(@view, @item)
  end
  
  it "render enumeration select" do
    setup_mocks
    @ar.enumeration = %w{ A B C }
    choices = [['Unassigned', nil], ['A', 'A'], ['B', 'B'], ['C', 'C']]
    @view.should_receive(:select).with('model', 'column', choices).once
    @ar.render_enumeration_select(@view, @item)
  end
  
  it "render enumeration select with hash" do
    setup_mocks
    @ar.enumeration = { 'A' => 1, 'B' => 2, 'C' => 3 }
    choices = [['Unassigned', nil], ['A', 1], ['B', 2], ['C', 3]]
    @view.should_receive(:select).with('model', 'column', choices).once
    @ar.render_enumeration_select(@view, @item)
  end
  
  it "render enumeration select with 2d array" do
    setup_mocks
    @ar.enumeration = [['A', 1], ['B', 2], ['C', 3]]
    choices = [['Unassigned', nil], ['A', 1], ['B', 2], ['C', 3]]
    @view.should_receive(:select).with('model', 'column', choices).once
    @ar.render_enumeration_select(@view, @item)
  end
  
  it "render enumeration select with custom unassigned value" do
    setup_mocks
    @ar.enumeration = []
    @ar.unassigned_value = 'none'
    choices = [['none', nil]]
    @view.should_receive(:select).with('model', 'column', choices).once
    @ar.render_enumeration_select(@view, @item)
  end
  
  it "render enumeration select with html options" do
    setup_mocks
    @ar.enumeration = []
    @ar.html_options = { :class => 'foo_class' }
    @view.should_receive(:select).with('model', 'column', [["Unassigned", nil]], {}, { :class => 'foo_class' }).once
    @ar.render_enumeration_select(@view, @item)
  end
  
private
  def ar_column(name, human_name)
    flexmock(:name => name, :human_name => human_name)
  end
  
  def setup_mocks
    @view = flexmock(:controller_name => 'controller_name', :link_to_function => 'link')
    @item = flexmock(:id => 123, :column => 'render')
  end
end

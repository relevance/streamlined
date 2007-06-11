require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/association'

class Streamlined::Column::AssociationTest < Test::Unit::TestCase
  include Streamlined::Column
  
  def setup
    @ar_assoc = flexmock(:name => 'some_name', :class_name => 'SomeClass')
    @model = flexmock(:name => 'model')
    @association = Association.new(@ar_assoc, @model, :inset_table, :count)
  end
  
  # begin stub classes
  class ::SomeClass
    def self.find(args)
      [:item1, :item2, :item3]
    end
  end

  class ::AnotherClass
    def self.find(args)
      [:item4, :item5]
    end
  end
  # end stub classes
  
  # This will probably change as more stuff moves from ui into assocation
  def test_initializer
    assert_raise(ArgumentError) { Association.new(@ar_assoc, 'foo', 'bar') }
    assert_equal 'Some name', @association.human_name
    assert_instance_of(Streamlined::View::ShowViews::Count, @association.show_view)
    assert_instance_of(Streamlined::View::EditViews::InsetTable, @association.edit_view)
  end
  
  def test_belongs_to
    flexmock(@association, :underlying_association => flexmock(:macro => :belongs_to))
    assert @association.belongs_to?
  end
  
  def test_belongs_to_false
    flexmock(@association, :underlying_association => flexmock(:macro => :has_many))
    assert !@association.belongs_to?
  end
  
  def test_show_and_edit_view_symbol_args
    assert_kind_of Streamlined::View::ShowViews::Count, @association.show_view
    assert_kind_of Streamlined::View::EditViews::InsetTable, @association.edit_view
  end
  
  def test_show_and_edit_view_array_args
    a = Association.new(@ar_assoc, nil, [:inset_table], [:count])
    assert_kind_of Streamlined::View::ShowViews::Count, a.show_view
    assert_kind_of Streamlined::View::EditViews::InsetTable, a.edit_view
  end
  
  def test_show_and_edit_view_instance_args
    inset_table_class = Streamlined::View::EditViews::InsetTable
    count_class = Streamlined::View::ShowViews::Count
    
    a = Association.new(@ar_assoc, nil, inset_table_class.new, count_class.new)
    assert_kind_of count_class, a.show_view
    assert_kind_of inset_table_class, a.edit_view
  end

  def test_show_and_edit_view_bad_args
    assert_raise(ArgumentError) { a = Association.new(@ar_assoc, nil, [:inset_table], Object.new) }
    assert_raise(ArgumentError) { a = Association.new(@ar_assoc, nil, Object.new, [:count]) }
  end
  
  def test_items_for_select_with_one_associable
    flexmock(@association).should_receive(:associables).and_return([SomeClass]).once
    assert_equal [:item1, :item2, :item3], @association.items_for_select
  end
  
  def test_items_for_select_with_many_associables
    flexmock(@association).should_receive(:associables).and_return([SomeClass, AnotherClass]).twice
    expected = { 'SomeClass' => [:item1, :item2, :item3], 'AnotherClass' => [:item4, :item5] }
    assert_equal expected, @association.items_for_select
  end
  
  def test_render_td
    view = flexmock(:render => 'render', :controller_name => 'controller_name')
    item = flexmock(:id => 123)
    
    expected_js = "Streamlined.Relationships.open_relationship('InsetTable::some_name::123::SomeClass', this, '/controller_name')"
    view.should_receive(:link_to_function).with("Edit", expected_js).and_return('link').once
    view.should_receive(:crud_context).and_return(:list)
    
    expected = "<div id=\"InsetTable::some_name::123::SomeClass\">render</div>link"
    assert_equal expected, @association.render_td(view, item)
  end
  
  def test_render_td_with_read_only_true
    view = flexmock(:render => 'render', :controller_name => 'controller_name')
    item = flexmock(:id => 123)
    @association.read_only = true
    expected = "<div id=\"InsetTable::some_name::123::SomeClass\">render</div>"
    assert_equal expected, @association.render_td(view, item)
  end

  # Here is another way you could do the above test...
  # def test_render_td_with_readonly_true_another_way
  #   view = flexmock(:crud_context=>'edit')
  #   flexmock(@association) do |mock|
  #     mock.should_receive(:render_td_edit).and_return('edit').once
  #     mock.should_receive(:render_td_show).and_return('show').once
  #   end
  #   assert_equal 'edit', @association.render_td(view,nil)
  #   @association.read_only = true
  #   assert_equal 'show', @association.render_td(view,nil)
  # end
  
  def test_render_td_edit
    view, item = view_and_item_mocks_for_render_td_edit
    @association.render_td_edit(view, item)
  end
  
  def test_render_td_edit_with_unassigned_value_set
    view, item = view_and_item_mocks_for_render_td_edit(:unassigned_value => 'none')
    @association.unassigned_value = 'none'
    @association.render_td_edit(view, item)
  end
  
  def test_render_td_edit_with_wrapper_set
    @association.wrapper = Proc.new { |c| "<<<#{c}>>>" }
    assert_equal '<<<[TBD: editable associations]>>>', @association.render_td_edit(*view_and_item_mocks)
  end
  
  def test_render_td_list
    expected = "<div id=\"InsetTable::some_name::123::SomeClass\">render</div>link"
    assert_equal expected, @association.render_td_list(*view_and_item_mocks)
  end
  
  def test_render_td_list_with_create_only_true
    @association.create_only = true
    expected = "<div id=\"InsetTable::some_name::123::SomeClass\">render</div>"
    assert_equal expected, @association.render_td_list(*view_and_item_mocks)
  end
  
  def test_render_td_list_with_read_only_true
    @association.read_only = true
    expected = "<div id=\"InsetTable::some_name::123::SomeClass\">render</div>"
    assert_equal expected, @association.render_td_list(*view_and_item_mocks)
  end
  
  def test_render_td_list_with_edit_in_list_false
    @association.edit_in_list = false
    expected = "<div id=\"InsetTable::some_name::123::SomeClass\">render</div>"
    assert_equal expected, @association.render_td_list(*view_and_item_mocks)
  end
  
  def test_render_td_edit_when_item_does_not_respond_to_name_id_method
    assert_equal '[TBD: editable associations]', @association.render_td_edit(nil, nil)
  end
  
  def test_render_quick_add
    view = flexmock(:image_tag => '<img src="plus.gif"/>', :url_for => '/people/quick_add')
    expected_args = [ '<img src="plus.gif"/>', "Streamlined.QuickAdd.open('/people/quick_add')" ]
    flexmock(view).should_receive(:link_to_function).with(*expected_args).and_return('link').once
    assert_equal 'link', @association.render_quick_add(view)
  end
  
  def view_and_item_mocks(view_attrs={})
    view = flexmock(:render => 'render', :controller_name => 'controller_name', :link_to_function => 'link')
    item = flexmock(:id => 123)
    [view, item]
  end
  
  def view_and_item_mocks_for_render_td_edit(options={:unassigned_value => 'Unassigned'})
    item = flexmock(:respond_to? => true, :some_name => nil)
    (view = flexmock).should_receive(:select).with('model', 'some_name_id', [[options[:unassigned_value], nil], :foo], :selected => nil).once
    items = flexmock(:collect => [:foo])
    flexmock(@association) do |mock|
      mock.should_receive(:items_for_select).and_return(items).once
      mock.should_receive(:column_can_be_unassigned?).with(@model, :some_name_id).and_return(true).once
      mock.should_receive(:belongs_to? => false).once
    end
    [view, item]
  end
end
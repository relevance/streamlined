require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/association'

class Streamlined::Column::AssociationTest < Test::Unit::TestCase
  include Streamlined::Column
  
  def setup
    @ar_assoc = flexmock
    @ar_assoc.should_expect do |o|
      o.name.returns('SomeName')
      o.class_name.returns('klass')
    end
  end
  
  # This will probably change as more stuff moves from ui into assocation
  def test_initializer
    assert_raise(ArgumentError) { Association.new(@ar_assoc, 'foo', 'bar') }
    a = Association.new(@ar_assoc, :inset_table, :count)
    assert_equal 'Somename', a.human_name
    assert_instance_of(Streamlined::View::ShowViews::Count, a.show_view)
    assert_instance_of(Streamlined::View::EditViews::InsetTable, a.edit_view)
  end
  
  def test_show_and_edit_view_symbol_args
    a = Association.new(@ar_assoc, :inset_table, :count)
    assert_kind_of Streamlined::View::ShowViews::Count, a.show_view
    assert_kind_of Streamlined::View::EditViews::InsetTable, a.edit_view
  end
  
  def test_show_and_edit_view_array_args
    a = Association.new(@ar_assoc, [:inset_table], [:count])
    assert_kind_of Streamlined::View::ShowViews::Count, a.show_view
    assert_kind_of Streamlined::View::EditViews::InsetTable, a.edit_view
  end
  
  def test_show_and_edit_view_instance_args
    inset_table_class = Streamlined::View::EditViews::InsetTable
    count_class = Streamlined::View::ShowViews::Count
    
    a = Association.new(@ar_assoc, inset_table_class.new, count_class.new)
    assert_kind_of count_class, a.show_view
    assert_kind_of inset_table_class, a.edit_view
  end
  
  def test_render_td
    view = flexmock(:render => 'render', :controller => flexmock(:url_for => 'controller_url'))
    expected_js = "Streamlined.Relationships.open_relationship('InsetTable::SomeName::123::klass', this, 'controller_url')"
    view.should_receive(:link_to_function).with("Edit", expected_js).and_return('link').once
    
    a = Association.new(@ar_assoc, :inset_table, :count)
    expected = "<div id=\"InsetTable::SomeName::123::klass\">render</div>link"
    assert_equal expected, a.render_td(view, flexmock(:id => 123))
  end
end
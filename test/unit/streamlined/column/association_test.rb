require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/association'

class Streamlined::Column::AssociationTest < Test::Unit::TestCase
  include Streamlined::Column
  
  def setup
    @ar_assoc = flexmock("ar")
    @ar_assoc.should_expect do |o|
      o.name.returns("SomeName")
    end
  end
  
  # This will probably change as more stuff moves from ui into assocation
  def test_initializer
    assert_raise(ArgumentError) {Association.new(@ar_assoc,"foo","bar")}
    a = Association.new(@ar_assoc,:inset_table,:count)
    assert_equal "Somename", a.human_name
    assert_instance_of(Streamlined::View::ShowViews::Count,a.show_view)
    assert_instance_of(Streamlined::View::EditViews::InsetTable,a.edit_view)
  end
  
  def test_show_and_edit_view_symbol_args
    a = Association.new(@ar_assoc,:inset_table,:count)
    assert_kind_of Streamlined::View::ShowViews::Count, a.show_view
    assert_kind_of Streamlined::View::EditViews::InsetTable, a.edit_view
  end
  
  def test_show_and_edit_view_array_args
    a = Association.new(@ar_assoc,[:inset_table],[:count])
    assert_kind_of Streamlined::View::ShowViews::Count, a.show_view
    assert_kind_of Streamlined::View::EditViews::InsetTable, a.edit_view
  end
  
  def test_show_and_edit_view_instance_args
    a = Association.new(@ar_assoc,
                        Streamlined::View::EditViews::InsetTable.new,
                        Streamlined::View::ShowViews::Count.new)
    assert_kind_of Streamlined::View::ShowViews::Count, a.show_view
    assert_kind_of Streamlined::View::EditViews::InsetTable, a.edit_view
  end
end
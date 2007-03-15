require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/column/association'

class Streamlined::Column::AssociationTest < Test::Unit::TestCase
  include Streamlined::Column
  include FlexMock::TestCase
  
  # This will probably change as more stuff moves from ui into assocation
  def test_initializer
    ar_assoc = flexmock("ar")
    ar_assoc.should_expect do |o|
      o.name.returns("SomeName")
    end
    assert_raise(ArgumentError) {Association.new(ar_assoc,"foo","bar")}
    a = Association.new(ar_assoc,:inset_table,:count)
    assert_equal "Somename", a.human_name
    assert_instance_of(Streamlined::View::ShowViews::Count,a.show_view)
    assert_instance_of(Streamlined::View::EditViews::InsetTable,a.edit_view)
  end
end
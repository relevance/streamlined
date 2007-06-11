require File.join(File.dirname(__FILE__), '../../test_functional_helper')
require 'streamlined/reflection'

class Streamlined::UIFunctionalTest < Test::Unit::TestCase
  def setup
    @ui = Class.new(Streamlined::UI)
    @ui.model = Poet
  end
  
  def test_all_columns
    assert_equal_sets([:id,:first_name,:poems,:last_name],@ui.all_columns.map{|x| x.name.to_sym})
  end

  def test_default_user_columns
    assert_equal_sets([:first_name,:poems,:last_name],@ui.user_columns.map{|x| x.name.to_sym})
  end
  
  def test_user_columns_override
    assert_equal nil, @ui.instance_variable_get(:@user_columns)
    @ui.user_columns :first_name, :last_name
    assert_enum_of_same [@ui.scalars[:first_name], @ui.scalars[:last_name]],
                        @ui.user_columns
  end
  
  def test_nonexistent_column
    assert_raise(Streamlined::Error) {@ui.user_columns(:nonexistent)}
  end
  
  def test_read_only_column
    @ui.user_columns :first_name, {:read_only=>true}, :last_name
    assert_equal true, @ui.scalars[:first_name].read_only
    assert_equal false, @ui.scalars[:last_name].read_only
  end
  
  def test_view_specific_columns
    @ui.user_columns :first_name, :last_name
    assert_equal false, @ui.scalars[:first_name].read_only
    assert_equal false, @ui.scalars[:last_name].read_only
    assert_same @ui.show_columns, @ui.user_columns
    @ui.show_columns :first_name, {:read_only=>true}, :last_name, {:read_only=>true}
    assert_not_same @ui.show_columns, @ui.user_columns
    assert_equal true, @ui.show_columns.first.read_only
    assert_equal true, @ui.show_columns.last.read_only
  end
  
  def test_can_find_instance_method_when_declared
    @ui.list_columns :first_name, :last_name, :arbitrary_instance_method
    assert_equal 3, @ui.list_columns.length
  end
  
  def test_cannot_find_instance_method_when_not_declared
    assert_raise(Streamlined::Error) {@ui.list_columns :first_name, :last_name, :arbitrary_instance_method_2}
  end

  def test_id_fragment
    assert_equal "Count", @ui.id_fragment(Poet.reflect_on_association(:poems), "show")
    assert_equal "Membership", @ui.id_fragment(Poet.reflect_on_association(:poems), "edit")
  end      
  
  def test_reflect_on_model_with_no_delegates
    assert_equal({}, @ui.reflect_on_delegates)
  end
              
  # TODO: hash storage of name/column pairs will result in name collisions if 
  # two different delegates have the same column names. Is this intentional?
  def test_reflect_on_model_with_delegates
    @ui.model = Authorship
    delegate_hash = @ui.reflect_on_delegates
    assert_equal_sets [:articles, :first_name, :authorships, :id, :books, :last_name], delegate_hash.keys
    assert_equal_sets [Streamlined::Column::Association, Streamlined::Column::ActiveRecord], delegate_hash.values.map(&:class)
  end
end
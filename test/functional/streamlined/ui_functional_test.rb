require File.join(File.dirname(__FILE__), '../../test_functional_helper')
require 'streamlined/reflection'

class Streamlined::UIFunctionalTest < Test::Unit::TestCase
  def setup
    Streamlined::Registry.reset
    @poet_ui = Streamlined.ui_for(Poet)
    @poem_ui = Streamlined.ui_for(Poem) do
      list_columns :text,
                   :text_with_div,
                   :poet, { :filter_column => "first_name" }
    end
  end
  
  def test_all_columns
    assert_equal_sets([:id,:first_name,:poems,:last_name],@poet_ui.all_columns.map{|x| x.name.to_sym})
  end

  def test_default_user_columns
    assert_equal_sets([:first_name,:poems,:last_name],@poet_ui.user_columns.map{|x| x.name.to_sym})
  end
  
  def test_user_columns_override
    assert_equal nil, @poet_ui.instance_variable_get(:@user_columns)
    @poet_ui.user_columns :first_name, :last_name
    assert_enum_of_same [@poet_ui.scalars[:first_name], @poet_ui.scalars[:last_name]],
                        @poet_ui.user_columns
  end
  
  def test_nonexistent_column
    assert_raise(Streamlined::Error) {@poet_ui.user_columns(:nonexistent)}
  end
  
  def test_read_only_column
    @poet_ui.user_columns :first_name, {:read_only=>true}, :last_name
    assert_equal true, @poet_ui.scalars[:first_name].read_only
    assert_equal false, @poet_ui.scalars[:last_name].read_only
  end
  
  def test_view_specific_columns
    @poet_ui.user_columns :first_name, :last_name
    assert_equal false, @poet_ui.scalars[:first_name].read_only
    assert_equal false, @poet_ui.scalars[:last_name].read_only
    assert_same @poet_ui.show_columns, @poet_ui.user_columns
    @poet_ui.show_columns :first_name, {:read_only=>true}, :last_name, {:read_only=>true}
    assert_not_same @poet_ui.show_columns, @poet_ui.user_columns
    assert_equal true, @poet_ui.show_columns.first.read_only
    assert_equal true, @poet_ui.show_columns.last.read_only
  end
  
  def test_can_find_instance_method_when_declared
    @poet_ui.list_columns :first_name, :last_name, :arbitrary_instance_method
    assert_equal 3, @poet_ui.list_columns.length
  end
  
  def test_cannot_find_instance_method_when_not_declared
    assert_raise(Streamlined::Error) {@poet_ui.list_columns :first_name, :last_name, :arbitrary_instance_method_2}
  end

  def test_id_fragment
    assert_equal "Count", @poet_ui.id_fragment(Poet.reflect_on_association(:poems), "show")
    assert_equal "Membership", @poet_ui.id_fragment(Poet.reflect_on_association(:poems), "edit")
  end      
  
  def test_reflect_on_model_with_no_delegates
    assert_equal({}, @poet_ui.reflect_on_delegates)
  end
              
  # TODO: hash storage of name/column pairs will result in name collisions if 
  # two different delegates have the same column names. Is this intentional?
  def test_reflect_on_model_with_delegates
    @poet_ui.model = Authorship
    delegate_hash = @poet_ui.reflect_on_delegates
    assert_equal_sets [:articles, :first_name, :full_name, :authorships, :id, :books, :last_name], delegate_hash.keys
    assert_equal_sets [Streamlined::Column::Addition, Streamlined::Column::Association, Streamlined::Column::ActiveRecord], delegate_hash.values.map(&:class)
  end
  
  def test_conditions_by_like_with_associations
    expected = "poems.text LIKE '%value%' OR poets.first_name LIKE '%value%'"
    assert_equal expected, @poem_ui.conditions_by_like_with_associations("value")
  end

  def test_conditions_by_like_with_associations_for_unconventional_table_names
    expected = "people.first_name LIKE '%value%' OR people.last_name LIKE '%value%'"
    assert_equal expected, Streamlined.ui_for(Unconventional).conditions_by_like_with_associations("value")
  end
  
  def test_columns_not_aliased_between_scalars_and_delegates
    assert_not_nil(poem_first_name = @poem_ui.column(:first_name))
    assert_not_nil(poet_first_name = @poet_ui.column(:first_name))
  end
end

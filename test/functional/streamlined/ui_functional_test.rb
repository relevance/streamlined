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
  
  def test_user_columns_act_as_template_for_other_column_groups
    @poet_ui.user_columns :first_name, {:read_only => true}, :last_name
    @poet_ui.list_columns :first_name, :last_name, {:read_only => true}
    assert_equal true, @poet_ui.scalars[:first_name].read_only, "settings shared from user_columns"
    assert_equal false, @poet_ui.scalars[:last_name].read_only, "settings not share from other column groups"
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
  
  # this allows us to declare ui options for dynamic methods not added yet
  def test_can_find_instance_method_when_not_declared
    assert_nothing_raised {@poet_ui.list_columns :first_name, :last_name, :nonexistent_method}
    assert_equal 3, @poet_ui.list_columns.length
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
    assert_key_set [:articles, :first_name, :full_name, :authorships, :id, :books, :last_name], delegate_hash
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
  
  def test_columns_not_aliased_between_column_groups
    template_column = @poet_ui.column(:first_name)
    list_column = @poet_ui.column(:first_name, :crud_context => :list)
    show_column = @poet_ui.column(:first_name, :crud_context => :show)
    assert_not_nil template_column
    assert_same template_column, list_column, "column groups share template until they are set"
    assert_same show_column, list_column, "column groups share template until they are set"
    @poet_ui.show_columns :first_name, :last_name
    assert_not_same show_column, @poet_ui.column(:first_name, :crud_context => :show), 
                    "show_columns should get its own copy of first_name"
    assert_same list_column, @poet_ui.column(:first_name, :crud_context => :list),
                    "list_columns should not be affected by setting show_columns"
    assert_same template_column, @poet_ui.column(:first_name),
                    "template columns should not be affected by setting show_columns"
  end
end

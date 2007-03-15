require File.join(File.dirname(__FILE__), '../../test_functional_helper')
require 'streamlined/reflection'

class Streamlined::UIFunctionalTest < Test::Unit::TestCase
  def setup
    @ui = Class.new(Streamlined::UI)
    @ui.model = Poet
  end
  
  def test_all_columns
    assert_equal_sets([:poet,:id,:first_name,:poems,:last_name],@ui.all_columns.map{|x| x.name.to_sym})
  end

  def test_default_user_columns
    assert_equal_sets([:poet,:first_name,:poems,:last_name],@ui.user_columns.map{|x| x.name.to_sym})
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
    assert_equal nil, @ui.scalars[:last_name].read_only
  end
  
  def test_view_specific_columns
    @ui.user_columns :first_name, :last_name
    assert_equal nil, @ui.scalars[:first_name].read_only
    assert_equal nil, @ui.scalars[:last_name].read_only
    assert_same @ui.show_columns, @ui.user_columns
    @ui.show_columns :first_name, {:read_only=>true}, :last_name, {:read_only=>true}
    assert_not_same @ui.show_columns, @ui.user_columns
    assert_equal true, @ui.show_columns.first.read_only
    assert_equal true, @ui.show_columns.last.read_only
  end
end
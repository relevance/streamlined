require File.join(File.dirname(__FILE__), '../../test_functional_helper')
require 'streamlined/reflection'

class Streamlined::UITest < Test::Unit::TestCase
  def setup
    @ui = Class.new(Streamlined::UI)
  end
  
  def test_all_columns
    @ui.model = Poet
    assert_equal_sets([:poet,:id,:first_name,:poems,:last_name],@ui.all_columns.map{|x| x.name.to_sym})
  end

  def test_default_user_columns
    @ui.model = Poet
    assert_equal_sets([:poet,:first_name,:poems,:last_name],@ui.user_columns.map{|x| x.name.to_sym})
  end
  
  def test_user_columns_override
    @ui.model = Poet
    assert_equal nil, @ui.instance_variable_get(:@user_columns)
    @ui.user_columns :first_name, :last_name
    assert_enum_of_same [@ui.scalars[:first_name], @ui.scalars[:last_name]],
                        @ui.user_columns
  end
end
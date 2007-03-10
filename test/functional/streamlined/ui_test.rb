require File.join(File.dirname(__FILE__), '../../test_functional_helper')
require 'streamlined/reflection'

class Streamlined::UITest < Test::Unit::TestCase
  def setup
    @ui = Streamlined::UI
  end
  
  def test_all_columns
    @ui.model = Poet
    assert_equal_sets([:poet,:id,:first_name,:poems,:last_name],@ui.all_columns.map{|x| x.name.to_sym})
  end

  def test_default_user_columns
    @ui.model = Poet
    assert_equal_sets([:poet,:first_name,:poems,:last_name],@ui.user_columns.map{|x| x.name.to_sym})
  end
end
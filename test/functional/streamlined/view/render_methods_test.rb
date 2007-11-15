require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/helpers/link_helper'

class Streamlined::View::RenderMethodsTest < Test::Unit::TestCase
  def setup
    stock_controller_and_view
  end
  
  def test_convert_partial_options_for_managed_partial
    assert_true @view.send(:managed_partials_include?, "list")
    assert_equal({:file=>"../../../templates/generic_views/_list", :layout=>false}, @view.convert_partial_options(:partial => "list"))
  end

  def test_convert_partial_options_leaves_non_managed_partial_alone
    assert_false @view.send(:managed_partials_include?, "foo")
    assert_equal({:partial=>"foo"}, @view.convert_partial_options(:partial => "foo"))
  end
  
  
end
require File.join(File.dirname(__FILE__), '../../test_functional_helper')
require 'streamlined/helpers/link_helper'

class Streamlined::HelperFunctionalTest < Test::Unit::TestCase
  fixtures :people
  def setup
    stock_controller_and_view
  end

  def test_invisible_link_to
    assert_equal '<a href="/people/show/1" style="display:none;"></a>', @view.invisible_link_to(:action=>"show", :id=>1)
  end
  
  def test_views_expose_controller_render_methods 
    render_methods = ['render_partials', 'render_tabs']
    assert_equal_sets render_methods, @view.methods & render_methods
  end
  
end
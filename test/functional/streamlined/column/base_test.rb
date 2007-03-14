require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/helpers/link_helper'

class Streamlined::Column::BaseTest < Test::Unit::TestCase
  fixtures :people
  def setup
    stock_controller_and_view
    @ui = Class.new(Streamlined::UI)
    @ui.model = Person
  end
  
  def test_render_straight_td
    assert_equal "Justin", @ui.column(:first_name).render_td(@view,people(:justin),@ui,@controller)
  end

  def test_render_link_td
    @ui.user_columns :first_name, {:link_to=>{:action=>"foo"}}
    assert_equal '<a href="/people/foo/1">Justin</a>', @ui.column(:first_name).render_td(@view,people(:justin),@ui,@controller)
    assert_equal '<a href="/people/foo/2">Stu</a>', @ui.column(:first_name).render_td(@view,people(:stu),@ui,@controller)
  end
  
  def test_render_popup_td
    @ui.user_columns :first_name, {:popup=>{:action=>"foo"}}
    assert_equal '<span class="sl-popup"><a href="/people/foo/1" style="display:none;"></a>Justin</span>', @ui.column(:first_name).render_td(@view,people(:justin),@ui,@controller)
  end
  
end
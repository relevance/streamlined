require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/helpers/link_helper'

class Streamlined::Helpers::LinkHelperTest < Test::Unit::TestCase
  fixtures :people
  def setup
    stock_controller_and_view
  end
  
  def test_guess_show_link_for
    assert_equal "(multiple)", @view.guess_show_link_for([])
    assert_equal "(unassigned)", @view.guess_show_link_for(nil)
    assert_equal "(unknown)", @view.guess_show_link_for(1)
    assert_equal '<a href="/people/show/1">1</a>', @view.guess_show_link_for(people(:justin))
  end
  
  # TODO: make link JavaScript unobtrusive!
  def test_link_to_new_model
    assert_equal "<a href=\"/people/new\"><img alt=\"New Person\" border=\"0\" src=\"/images/streamlined/add_16.png\" title=\"New Person\" /></a>", @view.link_to_new_model
  end

  def test_link_to_edit_model
    assert_equal "<a href=\"/people/edit/1\"><img alt=\"Edit Person\" border=\"0\" src=\"/images/streamlined/edit_16.png\" title=\"Edit Person\" /></a>", @view.link_to_edit_model(people(:justin))
  end
  
  def test_wrap_with_link
    assert_equal '<a href="/people/show/1">foo</a>', 
                 @view.wrap_with_link(:action=>"show", :id=>@item.id) {"foo"}
  end
  
end
require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/helpers/link_helper'

class Streamlined::Helpers::LinkHelperTest < Test::Unit::TestCase
  fixtures :people
  def setup
    @controller = PeopleController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @view = ActionView::Base.new
    @view.extend Streamlined::Helpers::LinkHelper
    @view.controller = @controller
    @item = Struct.new(:id).new(1)
    get 'index'
  end
  
  def test_guess_show_link_for
    assert_equal "(multiple)", @view.guess_show_link_for([])
    assert_equal "(unassigned)", @view.guess_show_link_for(nil)
    assert_equal "(unknown)", @view.guess_show_link_for(1)
    assert_equal '<a href="/people/show/1">1</a>', @view.guess_show_link_for(people(:justin))
  end
  
  def test_link_to_new_model
    assert_equal "<a href=\"/people/new\" onclick=\"Streamlined.Windows.open_local_window_from_url('New', '/people/new'); return false;\"><img alt=\"New \" border=\"0\" src=\"/images/streamlined/add_16.png\" title=\"New \" /></a>", @view.link_to_new_model
  end

  def test_link_to_edit_model
    assert_equal "<a href=\"/people/edit/1\" onclick=\"Streamlined.Windows.open_local_window_from_url('Edit', '/people/edit/1', 1); return false;\"><img alt=\"Edit\" border=\"0\" src=\"/images/streamlined/edit_16.png\" title=\"Edit\" /></a>", @view.link_to_edit_model(people(:justin))
  end
end
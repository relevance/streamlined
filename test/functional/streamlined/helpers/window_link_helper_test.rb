require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/helpers/window_link_helper'

require "#{RAILS_ROOT}/app/controllers/application"
class FoobarController < ApplicationController
end

class Streamlined::WindowLinkHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper 

  include Streamlined::Helpers::WindowLinkHelper
  attr_accessor :model_ui, :model_name, :item
  
  fixtures :people, :phone_numbers
  
  def setup 
    @controller = FoobarController.new
    request = ActionController::TestRequest.new
    response = ActionController::TestResponse.new
    request.relative_url_root = "/"
    request.path_parameters = {:action => 'new', :controller => 'foobar'}
    @controller.request = request
    @controller.instance_eval { @_params = {}} 
    @controller.send(:initialize_current_url)
  end
  
  def test_guess_show_link_for
    with_default_route do
      assert_equal "(multiple)", guess_show_link_for([])
      assert_equal "(unassigned)", guess_show_link_for(nil)
      assert_equal "(unknown)", guess_show_link_for(1)
      assert_equal "<a href=\"//people/show/1\">1</a>", guess_show_link_for(people(:justin))
      assert_equal "<a href=\"//phone_numbers/show/1\">1</a>", guess_show_link_for(phone_numbers(:number1))
    end
  end
  
  def test_link_to_new_model
    @model_ui = flexmock(:read_only => false, :quick_new_button => true)
    @model_name = "Foo"
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.Windows.open_local_window_from_url" <<
                   "('New', '//foobar/new', null); return false;\"><img alt=\"New Foo\" border=\"0\" " <<
                   "src=\"//images/streamlined/add_16.png\" title=\"New Foo\" /></a>", link_to_new_model
    end
  end
  
  def test_link_to_show_model
    @model_ui = flexmock(:read_only => false, :quick_new_button => true)
    @model_name = "Foo"
    item = flexmock(:id => 123)
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.Windows.open_local_window_from_url" <<
                   "('Show', '//foobar/show/123', null); return false;\"><img alt=\"Show Foo\" border=\"0\" " <<
                   "src=\"//images/streamlined/search_16.png\" title=\"Show Foo\" /></a>", link_to_show_model(item)
    end
  end
  
  def test_link_to_edit_model
    @model_ui = flexmock(:read_only => false, :quick_new_button => true)
    @model_name = "Foo"
    item = flexmock(:id => 123)
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.Windows.open_local_window_from_url" <<
                   "('Edit', '//foobar/edit/123', null); return false;\"><img alt=\"Edit Foo\" border=\"0\" " <<
                   "src=\"//images/streamlined/edit_16.png\" title=\"Edit Foo\" /></a>", link_to_edit_model(item)
    end
  end
  
  def test_link_to_delete_model
    item = flexmock(:id => 123)
    with_default_route do
      assert_equal "<a href=\"//foobar/destroy/123\" onclick=\"if (confirm('Are you sure?')) { " <<
                   "var f = document.createElement('form'); f.style.display = 'none'; " <<
                   "this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;" <<
                   "var m = document.createElement('input'); m.setAttribute('type', 'hidden'); " <<
                   "m.setAttribute('name', '_method'); m.setAttribute('value', 'post'); " <<
                   "f.appendChild(m);f.submit(); };return false;\"><img alt=\"Destroy\" " <<
                   "border=\"0\" src=\"//images/streamlined/delete_16.png\" " <<
                   "title=\"Destroy\" /></a>", link_to_delete_model(item)
    end
  end
  
  def test_link_to_next_page
    flexmock(self).should_receive(:page_link_style).and_return("").once
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.PageOptions.nextPage(); return false;\">" <<
                   "<img alt=\"Next Page\" border=\"0\" id=\"next_page\" " <<
                   "src=\"//images/streamlined/control-forward_16.png\" style=\"\" " <<
                   "title=\"Next Page\" /></a>", link_to_next_page
    end
  end
  
  def test_link_to_previous_page
    flexmock(self).should_receive(:page_link_style).and_return("").once
    with_default_route do
      assert_equal "<a href=\"#\" onclick=\"Streamlined.PageOptions.previousPage(); return false;\">" <<
                   "<img alt=\"Previous Page\" border=\"0\" id=\"previous_page\" " <<
                   "src=\"//images/streamlined/control-reverse_16.png\" style=\"\" " <<
                   "title=\"Previous Page\" /></a>", link_to_previous_page
    end
  end
  
  def test_page_link_style_without_pages
    @streamlined_item_pages = []
    assert_equal "display: none;", page_link_style
  end
  
  def test_page_link_style_with_previous_page
    @streamlined_item_pages = flexmock(:empty? => false, :current => flexmock(:previous => true))
    assert_equal "", page_link_style
  end
  
  def test_page_link_style_without_previous_page
    @streamlined_item_pages = flexmock(:empty? => false, :current => flexmock(:previous => false))
    assert_equal "display: none;", page_link_style
  end
  
  def test_link_to_new_model_when_quick_new_button_is_false
    @model_ui = flexmock(:read_only => false, :quick_new_button => false)
    assert_nil link_to_new_model
  end
  
  def test_wrap_with_link
    result = wrap_with_link("foo") { "bar" }
    assert_select root_node(result), "a[href=foo]", "bar"
  end
  
  def test_wrap_with_link_with_empty_block
    result = wrap_with_link("foo") {}
    assert_select root_node(result), "a[href=foo]", "foo"
  end
  
  def test_wrap_with_link_with_array
    result = wrap_with_link(["foo", {:action => "bar"}]) { "bat" }
    assert_select root_node(result), "a[href=foo][action=bar]", "bat"
  end
  
  def test_wrap_with_link_with_array_and_empty_block
    result = wrap_with_link(["foo", {:action => "bar"}]) {}
    assert_select root_node(result), "a[href=foo][action=bar]", "foo"
  end
  
  private
  def with_default_route
    with_routing do |set|
      set.draw do |map|
        map.connect ':controller/:action/:id'
        yield
      end
    end
  end
end

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
    assert_equal "(multiple)", guess_show_link_for([])
    assert_equal "(unassigned)", guess_show_link_for(nil)
    assert_equal "(unknown)", guess_show_link_for(1)
    assert_equal "<a href=\"//people/show/1\">1</a>", guess_show_link_for(people(:justin))
    assert_equal "<a href=\"//phone_numbers/show/1\">1</a>", guess_show_link_for(phone_numbers(:number1))
  end
  
  def test_link_to_new_model
    @model_ui = flexmock(:read_only => false, :quick_new_button => true)
    with_routing do |set|
      set.draw do |map|
        map.connect ':controller/:action/:id'
        assert_equal "<a href=\"#\" onclick=\"Streamlined.Windows.open_local_window_from_url" <<
                     "('', '//foobar/new', null); return false;\"><img alt=\"New \" border=\"0\" " <<
                     "src=\"//images/streamlined/add_16.png\" title=\"New \" /></a>", link_to_new_model
      end
    end
  end
  
  def test_link_to_new_model_when_quick_new_button_is_false
    @model_ui = flexmock(:read_only => false, :quick_new_button => false)
    assert_nil link_to_new_model
  end
end

require File.join(File.dirname(__FILE__), '../test_helper')
require 'streamlined_controller'
require 'streamlined_ui'
# Monkey patching ActionView. This sucks, but I got tired of trying to
# find how to get the base_path set.
class ActionView::Base
  def initialize(base_path = nil, assigns_for_first_render = {}, controller = nil)#:nodoc:
    @base_path, @assigns = base_path, assigns_for_first_render
    @assigns_added = nil
    @controller = controller
    @logger = controller && controller.logger 
    @base_path = File.join(RAILS_ROOT, "app/views")
  end
end

class PeopleController < ApplicationController
	acts_as_streamlined
end  

# TODO: this should go away once the UI class is optional
class PersonUI < Streamlined::UI
end

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

class StreamlinedControllerTest < Test::Unit::TestCase
  def setup
    @controller = PeopleController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    # Justin TODO: we need some kind of override like this to point to the templates during testing
    # class <<@controller
    #   def generic_view(template)
    #     File.join(File.dirname(__FILE__), '../../templates/generic_views', template)
    #   end
    # end
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = Person.create(:id=>3, :first_name=>'Test', :last_name=>'Person')
  end

  def test_index
    get :index
    assert_response :success
    assert_template '/streamlined/generic_views/list'
  end
  
  def test_list
    get :list
    assert_response :success
    assert_template '/streamlined/generic_views/list'
  end

  def test_show
    get :show, :id => 1
    assert_response :success
    assert_template '/streamlined/generic_views/_show'
    assert_not_nil assigns(:streamlined_item)
    assert assigns(:streamlined_item).valid?
  end
  
  def test_new
    get :new
    assert_response :success
    assert_template '/streamlined/generic_views/_new'
    assert_not_nil assigns(:streamlined_item)
  end

  def test_create
    assert_difference(Person, :count) do
      post :create, :person => {:first_name=>'Another', :last_name=>'Person'}
      assert_response :redirect
      assert_redirected_to :action => 'show', :layout=>'streamlined_window'
    end
  end
  
  def test_edit
    get :edit, :id => 1
    assert_response :success
    assert_template '/streamlined/generic_views/_edit'
    assert_not_nil assigns(:streamlined_item)
    assert assigns(:streamlined_item).valid?
  end
  
end

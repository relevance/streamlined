require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/controller/crud_methods'
require 'streamlined/controller/filter_methods'

describe "creating with has many relationships" do
  attr_reader :controller
  setup do
    stock_controller_and_view(PoetsController)
  end
  
  it "should save the has_many side after the parent" do
    params = {:poet => {:first_name => "John", :last_name => "Doe", :poems => ["1", "2"] } }
    post :create, params
    assigns(:streamlined_item).poem_ids.should == [1,2]
  end
  
  it "should just save the parent if there are no has_manies set" do
    params = {:poet => {:first_name => "John", :last_name => "Doe" } }
    assert_difference(Poet, :count) do
      post :create, params
    end
  end
  
end
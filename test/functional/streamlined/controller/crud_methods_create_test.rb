require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/controller/crud_methods'
require 'streamlined/controller/filter_methods'

describe "create with a db action filter" do
  attr_reader :controller
  setup do
    stock_controller_and_view(PoetsController)
  end
  
  it "should do a proc filter before the save" do
    @controller.class.before_streamlined_create(lambda { @poet.first_name = "Barack"; @poet.last_name = "Obama" })
    post :create, {:poet => {:first_name => "George", :last_name => "Bush" } }
    assigns(:streamlined_item).first_name.should == "Barack"
    assigns(:streamlined_item).last_name.should == "Obama"
  end
  
end

describe "creating with has many relationships" do
  attr_reader :controller
  setup do
    stock_controller_and_view(PoetsController)
  end
  
  it "should save the has_many side after the parent" do
    params = {:poet => {:first_name => "John", :last_name => "Doe", :poems => ["1", "2"] } }
    post :create, params
    assigns(:streamlined_item).poem_ids.sort.should == [1,2]
  end
  
  it "should just save the parent if there are no has_manies set" do
    params = {:poet => {:first_name => "John", :last_name => "Doe" } }
    assert_difference(Poet, :count) do
      post :create, params
    end
  end
  
end

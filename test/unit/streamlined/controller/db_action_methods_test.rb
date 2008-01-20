require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller/db_action_methods'

class StubController < ActionController::Base
  include Streamlined::Controller::DbActionMethods
  public :execute_before_streamlined_create_or_update_filter
end

describe "Streamlined::Controller::DbActionMethods" do
  
  def setup
    @controller = StubController.new
  end

  it "should call the method registered" do
    @controller.expects(:current_before_streamlined_create_or_update_filter).returns(:some_method)
    @controller.expects(:some_method).returns(:result)
    assert_equal :result, @controller.execute_before_streamlined_create_or_update_filter
  end
  
  it "should raise if trying to register an invalid filter" do
    @controller.expects(:current_before_streamlined_create_or_update_filter).returns(nil)
    lambda { @controller.execute_before_streamlined_create_or_update_filter }.should.
      raise(ArgumentError).
      message.should == "Invalid options for db_action_filter - must pass either a Proc or a Symbol, you gave [nil]"
  end
  
end

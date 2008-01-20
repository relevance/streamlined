require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller/db_action_methods'

class StubController < ActionController::Base
  include Streamlined::Controller::DbActionMethods
  public :execute_db_action_filter
end

describe "Streamlined::Controller::DbActionMethods" do
  
  def setup
    @controller = StubController.new
  end

  it "execute db action filter with symbol" do
    @controller.expects(:current_db_action_filter).returns(:some_method)
    @controller.expects(:some_method).returns(:result)
    assert_equal :result, @controller.execute_db_action_filter
  end
  
  it "execute db action filter with invalid filter" do
    begin 
      flexmock(@controller).should_receive(:current_db_action_filter).and_return(nil).once
      @controller.execute_db_action_filter
      flunk "Exception should have been thrown"
    rescue ArgumentError => e
      assert_equal "Invalid options for db_action_filter - must pass either a Proc or a Symbol, you gave [nil]", e.message
    end
  end
  
end

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
  
  it "execute db action filter with proc" do
    proc = Proc.new { "foo" }
    flexmock(@controller).should_receive(:current_db_action_filter).and_return(proc).once
    assert_equal "foo", @controller.execute_db_action_filter
  end
  
  it "execute db action filter with symbol" do
    flexmock(@controller) do |c|
      c.should_receive(:current_db_action_filter).and_return(:some_method).once
      c.should_receive(:some_method).and_return(:result).once
    end
    assert_equal :result, @controller.execute_db_action_filter
  end
  
  it "execute db action filter with invalid filter" do
    begin 
      flexmock(@controller).should_receive(:current_db_action_filter).and_return(nil).once
      @controller.execute_db_action_filter
      flunk "Exception should have been thrown"
    rescue ArgumentError => e
      assert_equal "Invalid options for db_action_filter", e.message
    end
  end
  
end

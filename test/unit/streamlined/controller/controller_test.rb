require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller'

require "#{RAILS_ROOT}/app/controllers/application"
class FooController < ApplicationController
end

describe "Streamlined::Controller" do
  include Streamlined::Controller::ClassMethods
  
  # verify that exception is logged and rethrown
  it "initialize with streamlined variables" do
    o = Object.new
    o.extend Streamlined::Controller::InstanceMethods
    logger = flexmock("logger") do |mock|
      mock.should_receive(:info).once
    end 
    flexmock(o, :streamlined_logger => logger)
    flexmock(Streamlined::Context::ControllerContext).should_receive(:new).and_raise(RuntimeError,"mocked!")
    assert_raise(RuntimeError) do
      o.send :initialize_streamlined_values
    end
  end
  
  it "deprecation of helper overrides" do
    c = FooController
    c.acts_as_streamlined
    assert_nil c.send(:instance_variable_get, :@helper_overrides)
    assert_raises(ArgumentError) do
      c.acts_as_streamlined :helpers => ["NEW HELPER"]
    end
  end
  
  it "streamlined model" do
    streamlined_model("Test")
    assert_equal "Test", model_name
    streamlined_model(stub(:name => "Tim"))
    assert_equal "Tim", 
                 model_name, 
                 "streamlined_model should extract name property" 
  end  
  
  it "render filter" do
    options = { :success => { :action => 'foo' }}
    render_filter :show, options
    assert_equal options, render_filters[:show]
  end
  
  it "db action filter" do
    db_action_filter :create, :save_instances
    assert_equal :save_instances, db_action_filters[:create]
  end
  
  it "filter readers default to empty hash" do
    assert_equal({}, filters)
    assert_equal({}, render_filters)
    assert_equal({}, db_action_filters)
  end
  
  it "count or find options" do
    assert_equal({}, count_or_find_options)
    count_or_find_options(:foo => :bar)
    assert_equal({:foo => :bar}, count_or_find_options)
    count_or_find_options(:abc => :def)
    assert_equal({:abc => :def}, count_or_find_options)
  end
end
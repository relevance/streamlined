require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller'

require "#{RAILS_ROOT}/app/controllers/application"
class FooController < ApplicationController
end

class Streamlined::ControllerTest < Test::Unit::TestCase
  include Streamlined::Controller::ClassMethods
  
  # verify that exception is logged and rethrown
  def test_initialize_with_streamlined_variables
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
  
  def test_act_as_streamlined
    c = FooController
    c.acts_as_streamlined
    assert_equal [], c.send(:instance_variable_get, :@helper_overrides)
    c.acts_as_streamlined :helpers => ["NEW HELPER"]
    assert_equal ["NEW HELPER"], c.send(:instance_variable_get, :@helper_overrides)
  end
  
  def test_streamlined_model
    streamlined_model("Test")
    assert_equal "Test", model_name
    streamlined_model(self)
    assert_equal "test_streamlined_model(Streamlined::ControllerTest)", 
                 model_name, 
                 "streamlined_model should extract name property" 
  end  
  
  def test_render_filter
    options = { :success => { :action => 'foo' }}
    render_filter :show, options
    assert_equal options, render_filters[:show]
  end
  
  def test_render_filters_defaults_to_empty_hash
    assert_equal({}, render_filters)
  end
end
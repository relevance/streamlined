require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller/quick_add_methods'

class StubClass
  attr_accessor :attrs
  def initialize(attrs={})
    @attrs = attrs
  end
end

class StubController < ActionController::Base
  include Streamlined::Controller::QuickAddMethods
  attr_accessor :crud_context, :instance, :model, :stub_class,
                :model_class_name, :model_name, :ui
end

class Streamlined::Controller::QuickAddMethodsTest < Test::Unit::TestCase
  # TODO: test these actions with a class that uses delegation
  
  def setup
    @controller = StubController.new
  end
  
  def test_quick_add
    build_param_and_render_mocks('quick_add')
    @controller.quick_add
    assert_equal :new, @controller.crud_context
    assert_correct_vars_set
  end
  
  def test_save_quick_add
    build_param_and_render_mocks('save_quick_add')
    flexmock(StubClass).new_instances.should_receive(:save).and_return(true).once
    @controller.save_quick_add
    assert_nil @controller.crud_context
    assert_correct_vars_set
  end
  
  def assert_correct_vars_set
    assert @controller.instance.is_a?(StubClass)
    assert @controller.model.is_a?(StubClass)
    assert @controller.stub_class.is_a?(StubClass)
    
    assert_equal 'StubClass', @controller.model_class_name
    assert_equal 'stub_class', @controller.model_name    
    assert_equal Streamlined::UI::Generic, @controller.ui
  end
  
  def build_param_and_render_mocks(template)
    flexmock(@controller) do |mock|
      mock.should_receive(:params => { :model_class_name => 'StubClass' }).at_least.once
      mock.should_receive(:render_or_redirect).with(:success, template).once
    end
  end
end
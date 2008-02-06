require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller/quick_add_methods'

class StubModel
  attr_accessor :attrs
  def initialize(attrs={})
    @attrs = attrs
  end
end

class StubController < ActionController::Base
  include Streamlined::Controller::QuickAddMethods
  attr_accessor :crud_context, :instance, :model, :stub_model,
                :model_class_name, :model_name, :ui
end

module QuickAddMethodsTestHelper
  def assert_correct_vars_set
    assert @controller.instance.is_a?(StubModel)
    assert @controller.model.is_a?(StubModel)
    assert @controller.stub_model.is_a?(StubModel)
    assert_equal 'StubModel', @controller.model_class_name
    assert_equal 'stub_model', @controller.model_name    
    assert_instance_of Streamlined::UI, @controller.ui
  end
  
  def build_param_and_render_mocks(template)
    @controller.stubs(:params).returns({ :model_class_name => 'StubModel' })
    @controller.expects(:render_or_redirect).with(:success, template)
  end
end


describe "Streamlined::Controller::QuickAddMethods for relational delegate" do
  # TODO: test these actions with a class that uses delegation
end

describe "Streamlined::Controller::QuickAddMethods for non-relational delegate" do
  include QuickAddMethodsTestHelper

  before do
    @controller = StubController.new
    StubModel.stubs(:delegate_targets).returns([:target])
    StubModel.stubs(:reflect_on_association).returns(nil)
  end
  
  it "quick add" do
    build_param_and_render_mocks('quick_add')
    @controller.quick_add
    assert_equal :new, @controller.crud_context
    assert_correct_vars_set
  end
  
  it "save quick add" do
    build_param_and_render_mocks('save_quick_add')
    StubModel.any_instance.expects(:save).returns(true)
    @controller.save_quick_add
    assert_nil @controller.crud_context
    assert_correct_vars_set
  end
end

describe "Streamlined::Controller::QuickAddMethods" do
  include QuickAddMethodsTestHelper
  
  before do
    @controller = StubController.new
  end
  
  it "quick add" do
    build_param_and_render_mocks('quick_add')
    @controller.quick_add
    assert_equal :new, @controller.crud_context
    assert_correct_vars_set
  end
  
  it "save quick add" do
    build_param_and_render_mocks('save_quick_add')
    StubModel.any_instance.expects(:save).returns(true)
    @controller.save_quick_add
    assert_nil @controller.crud_context
    assert_correct_vars_set
  end
  
  
end
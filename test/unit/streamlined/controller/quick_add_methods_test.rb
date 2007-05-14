require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller/quick_add_methods'

class StubClass
  attr_accessor :attrs
  def initialize(attrs={})
    @attrs = attrs
  end
end

class Streamlined::Controller::QuickAddMethodsTest < Test::Unit::TestCase
  include Streamlined::Controller::QuickAddMethods
  attr_accessor :crud_context, :instance
  
  # TODO: test these actions with a class that uses delegation
  
  def test_quick_add
    build_param_and_render_mocks('quick_add')
    quick_add
    assert_equal :new, crud_context
    assert instance.is_a?(StubClass)
  end
  
  def test_save_quick_add
    build_param_and_render_mocks('save_quick_add')
    flexmock(StubClass).new_instances.should_receive(:save).and_return(true).once
    save_quick_add
    assert_nil crud_context
    assert instance.is_a?(StubClass)
  end
  
  def build_param_and_render_mocks(template)
    flexmock(self) do |mock|
      mock.should_receive(:params => { :model_class_name => 'StubClass' })
      mock.should_receive(:render_or_redirect).with(:success, template).once
    end
  end
end
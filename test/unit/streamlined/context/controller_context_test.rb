require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/ui'

describe "Streamlined::Context::ControllerContext" do
  
  def setup
    @context = Streamlined::Context::ControllerContext.new
    @context.model_name = "String"
  end
  
  it "model ui" do
    assert_instance_of Streamlined::UI, @context.model_ui
    context2 = Streamlined::Context::ControllerContext.new
    context2.model_name = "Integer"
    assert_not_equal context2.model_ui, @context.model_ui, "every model class gets its own anonymous subclass for ui"
  end
  
  it "model ui uses passed model class" do
    assert_equal String, @context.model_ui.model
  end
end
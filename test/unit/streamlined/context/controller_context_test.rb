require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/ui'

class Streamlined::Context::ControllerContextTest < Test::Unit::TestCase
  
  def setup
    @context = Streamlined::Context::ControllerContext.new
    @context.model_name = "String"
  end
  
  def test_model_ui
    assert_equal Streamlined::UI::Generic, @context.model_ui.ancestors[1] # anonymous subclass!
    context2 = Streamlined::Context::ControllerContext.new
    context2.model_name = "Integer"
    assert_not_equal context2.model_ui, @context.model_ui, "every model class gets its own anonymous subclass for ui"
  end
  
  def test_model_ui_uses_passed_model_class
    assert_equal String, @context.model_ui.model
  end
  
  def test_render_filters
    context = Streamlined::Context::ControllerContext.new
    filters = { :foo => :bar }
    context.render_filters = filters
    assert_equal filters, context.render_filters
  end
end
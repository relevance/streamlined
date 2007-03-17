require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/ui'

class Streamlined::Context::ControllerContextTest < Test::Unit::TestCase
  def setup
    @context = Streamlined::Context::ControllerContext.new
    @context.model_name = "String"
  end
  def test_model_ui
    assert_equal Streamlined::UI::Generic, @context.model_ui.ancestors.first
  end
end
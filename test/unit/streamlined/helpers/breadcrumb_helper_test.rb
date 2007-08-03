require File.join(File.dirname(__FILE__), "../../../test_helper")
require "streamlined/helpers/breadcrumb_helper"

class Streamlined::BreadcrumbHelperTest < Test::Unit::TestCase
  include Streamlined::Helpers::BreadcrumbHelper

  def test_breadcrumb_defaults_to_false
    assert !breadcrumb
  end

  def test_render_breadcrumb_for_list_context
    assert_render_breadcrumb(:list)
    assert_select root_node(render_breadcrumb), "div[id=breadcrumb]", "Models"
  end

  def test_render_breadcrumb_for_edit_context
    assert_render_breadcrumb(:edit)
    flexmock(self).should_receive(:header_text).with("Edit").and_return("Edit Some Name").once
    assert_select root_node(render_breadcrumb), "div[id=breadcrumb]", "Models < Edit Some Name" 
  end

  def test_render_breadcrumb_for_new_context
    assert_render_breadcrumb(:new)
    flexmock(self).should_receive(:header_text).with("New").and_return("New Some Name").once
    assert_select root_node(render_breadcrumb), "div[id=breadcrumb]", "Models < New Some Name" 
  end

  def test_render_breadcrumb_for_other_context
    assert_render_breadcrumb(:foo)
    flexmock(self).should_receive(:header_text).with_no_args.and_return("Foo").once
    assert_select root_node(render_breadcrumb), "div[id=breadcrumb]", "Models < Foo" 
  end
  
  private 
  def assert_render_breadcrumb(context)
    flexmock(self) do |m|
      m.should_receive(:link_to).with("models", {:action => "list"}).and_return("Models").once
      m.should_receive(:model_name => "model").once
      m.should_receive(:crud_context => context).at_least.once
    end
  end
end
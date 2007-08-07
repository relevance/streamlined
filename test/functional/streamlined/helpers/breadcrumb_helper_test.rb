require File.join(File.dirname(__FILE__), "../../../test_functional_helper")
require "streamlined/helpers/breadcrumb_helper"

class Streamlined::BreadcrumbHelperTest < Test::Unit::TestCase
  fixtures :people

  def setup
    stock_controller_and_view
  end

  def test_breadcrumb_defaults_to_false
    assert !@view.breadcrumb
  end
  
  def test_render_breadcrumb_uses_default_trail
    assert_select root_node(@view.render_breadcrumb), "div[id=breadcrumb]", "Home < People"
  end

  def test_render_breadcrumb_for_list_context
    assert_render_breadcrumb(:list)
    assert_select root_node(@view.render_breadcrumb), "div[id=breadcrumb]", "Home < Fancy Models"
  end

  def test_render_breadcrumb_for_edit_context
    assert_render_breadcrumb_for_sub_context(:edit)
    flexmock(@view) do |m|
      m.should_receive(:prefix_for_crud_context).and_return("Edit").once
      m.should_receive(:header_text).with("Edit").and_return("Edit Some Name").once
    end
    assert_select root_node(@view.render_breadcrumb), "div[id=breadcrumb]", "Home < Fancy Models < Edit Some Name" 
  end

  def test_render_breadcrumb_for_new_context
    assert_render_breadcrumb_for_sub_context(:new)
    flexmock(@view) do |m|
      m.should_receive(:prefix_for_crud_context).and_return("New").once
      m.should_receive(:header_text).with("New").and_return("New Some Name").once
    end
    assert_select root_node(@view.render_breadcrumb), "div[id=breadcrumb]", "Home < Fancy Models < New Some Name" 
  end

  def test_render_breadcrumb_for_other_context
    assert_render_breadcrumb_for_sub_context(:foo)
    flexmock(@view) do |m| 
      m.should_receive(:prefix_for_crud_context).and_return(nil).once    
      m.should_receive(:header_text).with(nil).and_return("Foo").once
    end
    assert_select root_node(@view.render_breadcrumb), "div[id=breadcrumb]", "Home < Fancy Models < Foo" 
  end
  
  private 
  def assert_render_breadcrumb(context)
    flexmock(@view) do |m|
      m.should_receive(:link_to).with("Home", "/").and_return("Home").once
      m.should_receive(:model_name => "FancyModel").once
      m.should_receive(:crud_context => context).at_least.once
    end
  end

  def assert_render_breadcrumb_for_sub_context(context)
    flexmock(@view).should_receive(:link_to).with("Fancy Models", {:action => "list"}).and_return("Fancy Models").once
    assert_render_breadcrumb(context)
  end
end
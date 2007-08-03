require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/helpers/header_helper'

class HeaderHelperTest < Test::Unit::TestCase
  
  class FancyController
    include Streamlined::Helpers::HeaderHelper
    attr_accessor :instance, :model_name
  end
  
  def setup
    @controller = FancyController.new
    @controller.model_name = "Fancy Model"
  end
  
  def test_render_show_header
    flexmock(@controller).should_receive(:crud_context => :show)
    assert_header_text "Fancy Model", @controller.render_show_header
  end
  
  def test_render_edit_header
    assert_header_text "Edit Fancy Model", @controller.render_edit_header
  end

  def test_render_new_header
    assert_header_text "New Fancy Model", @controller.render_new_header
  end

  private
  def assert_header_text(expected_header_text, actual_header_html)
    root = HTML::Document.new(actual_header_html).root
    assert_select root, "div[class=streamlined_header]" do
      assert_select "h2", expected_header_text
    end
  end  
end

require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/helpers/header_helper'
require 'ostruct'

class HeaderHelperTest < Test::Unit::TestCase
  def setup
    @obj = OpenStruct.new
    @obj.extend Streamlined::Helpers::HeaderHelper
    @obj.model_name = "Fancy Model"
    @obj.instance = nil
  end
  
  def test_render_show_header
    assert_header_text "Fancy Model", @obj.render_show_header
  end
  
  def test_render_show_header_with_named_instance
    @obj.instance = flexmock(:name => 'Ishmael')
    assert_header_text "Ishmael", @obj.render_show_header
  end
  
  def test_render_edit_header
    assert_header_text "Editing Fancy Model", @obj.render_edit_header
  end  

  def test_render_new_header
    assert_header_text "New Fancy Model", @obj.render_new_header
  end  
  
  def assert_header_text(expected_header_text, actual_header_html)
    root = HTML::Document.new(actual_header_html).root
    assert_select root, "div[class=streamlined_header]" do
      assert_select "h2", expected_header_text
    end
  end  
  
end

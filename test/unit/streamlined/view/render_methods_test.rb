require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/view/render_methods'

class Streamlined::View::RenderMethodsTest < Test::Unit::TestCase
  include Streamlined::View::RenderMethods
  
  def test_controller_name
    flexmock(self).should_receive(:controller => flexmock(:controller_name => "foo")).once
    assert_equal "foo", controller_name
  end
  
  def test_convert_partial_options_for_generic
    setup_mocks(false)
    options = {:partial=>"list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:layout=>false, :file=>generic_view("_list"), :other=>"1"}, options)
  end

  def test_convert_partial_options_and_layout_for_generic
    setup_mocks(false)
    options = {:partial=>"list", :other=>"1", :layout=>true}
    convert_partial_options(options)
    assert_equal({:layout=>true, :file=>generic_view("_list"), :other=>"1"}, options)
  end

  def test_convert_partial_options_for_specific
    setup_mocks(true)
    options = {:partial=>"list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:partial=>"list", :other=>"1"}, options)
  end
  
  private
  def setup_mocks(template_exists)
    flexstub(self) do |s|
      s.should_receive(:specific_template_exists?).and_return(template_exists)
      s.should_receive(:controller_path).and_return("people")
      s.should_receive(:managed_partials_include?).and_return(true)
    end
  end
end
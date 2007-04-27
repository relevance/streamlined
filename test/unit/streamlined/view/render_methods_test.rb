require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/view/render_methods'

class Streamlined::View::RenderMethodsTest < Test::Unit::TestCase
  include Streamlined::View::RenderMethods
  
  # begin stub methods
  def controller_name
    "people"
  end
  
  def managed_views_include?(action)
    true
  end

  def managed_partials_include?(action)
    true
  end
  # end stub methods
  
  def pretend_template_exists(exists)
    flexstub(self) do |stub|
      stub.should_receive(:specific_template_exists?).and_return(exists)
    end
  end
  
  def test_convert_partial_options_for_generic
    pretend_template_exists(false)
    options = {:partial=>"list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:layout=>false, :file=>"../../../templates/generic_views/_list", :other=>"1"}, options)
  end

  def test_convert_partial_options_and_layout_for_generic
    pretend_template_exists(false)
    options = {:partial=>"list", :other=>"1", :layout=>true}
    convert_partial_options(options)
    assert_equal({:layout=>true, :file=>"../../../templates/generic_views/_list", :other=>"1"}, options)
  end

  def test_convert_partial_options_for_specific
    pretend_template_exists(true)
    options = {:partial=>"list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:partial=>"list", :other=>"1"}, options)
  end
end
require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller/render_methods'

class Streamlined::Controller::RenderMethodsTest < Test::Unit::TestCase
  include Streamlined::Controller::RenderMethods
  include FlexMock::TestCase
  
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
  
  def test_convert_action_options_for_generic
    flexstub(self) do |stub|
      stub.should_receive(:specific_template_exists?).and_return(false)
    end
    options = {:action=>"new", :id=>"1"}
    convert_action_options(options)
    assert_equal({:template=>"../../../templates/generic_views/new", :id=>"1"}, options)
  end

  def test_convert_action_options_for_specific
    flexstub(self) do |stub|
      stub.should_receive(:specific_template_exists?).and_return(true)
    end
    options = {:action=>"new", :id=>"1"}
    convert_action_options(options)
    assert_equal({:action=>"new", :id=>"1"}, options)
  end

  def test_convert_partial_options_for_generic
    flexstub(self) do |stub|
      stub.should_receive(:specific_template_exists?).and_return(false)
    end
    options = {:partial=>"_list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:template=>"../../../templates/generic_views/_list", :other=>"1"}, options)
  end

  def test_convert_partial_options_for_specific
    flexstub(self) do |stub|
      stub.should_receive(:specific_template_exists?).and_return(true)
    end
    options = {:partial=>"_list", :other=>"1"}
    convert_partial_options(options)
    assert_equal({:partial=>"_list", :other=>"1"}, options)
  end
end
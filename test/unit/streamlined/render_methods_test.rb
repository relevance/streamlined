require File.join(File.dirname(__FILE__), '../../test_helper')
require 'streamlined/render_methods'

class Streamlined::RenderMethodsTest < Test::Unit::TestCase
  include Streamlined::RenderMethods
  
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
  
  def test_specific_template_exists?
    assert specific_template_exists?("templates/template")
    assert specific_template_exists?("templates/template.rhtml")
    assert specific_template_exists?("templates/template.rxml")
    assert !specific_template_exists?("templates/template.rpdf")
    assert !specific_template_exists?("templates/non_existing_template")
  end
  
  def test_convert_action_options_for_generic
    pretend_template_exists(false)
    options = {:action=>"new", :id=>"1"}
    convert_action_options(options)
    assert_equal({:template=>"../../../templates/generic_views/new", :id=>"1"}, options)
  end

  def test_convert_action_options_for_specific
    pretend_template_exists(true)
    options = {:action=>"new", :id=>"1"}
    convert_action_options(options)
    assert_equal({:action=>"new", :id=>"1"}, options)
  end
  
  # partials are view/controller specific and are tested separately


end
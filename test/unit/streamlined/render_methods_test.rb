require File.join(File.dirname(__FILE__), '../../test_helper')
require 'streamlined/render_methods'

class Streamlined::RenderMethodsTest < Test::Unit::TestCase
  include Streamlined::RenderMethods
  
  # begin stub methods
  def controller_name
    "people"
  end
  
  def controller_path
    "people"
  end
  # end stub methods
  
  def test_specific_template_exists?
    assert specific_template_exists?("templates/template")
    assert specific_template_exists?("templates/template.rhtml")
    assert specific_template_exists?("templates/template.rxml")
    assert !specific_template_exists?("templates/template.rpdf")
    assert !specific_template_exists?("templates/non_existing_template")
  end
  
  def test_convert_action_options_for_generic
    @managed_views = ['new']
    options = {:action=>"new", :id=>"1"}
    convert_action_options(options)
    assert_equal({:template=>generic_view("new"), :id=>"1"}, options)
  end

  def test_convert_action_options_for_specific
    @managed_partials = ['new']
    options = {:action=>"new", :id=>"1"}
    convert_action_options(options)
    assert_equal({:action=>"new", :id=>"1"}, options)
  end
  
  # partials are view/controller specific and are tested separately

end
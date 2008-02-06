require File.expand_path(File.join(File.dirname(__FILE__), '../../test_helper'))
require 'streamlined/render_methods'

describe "Streamlined::RenderMethods" do
  include Streamlined::RenderMethods
  
  # begin stub methods
  def controller_name
    "people"
  end
  
  def controller_path
    "people"
  end
  # end stub methods
  
  it "specific template exists?" do
    assert specific_template_exists?("templates/template")
    assert specific_template_exists?("templates/template.rhtml")
    assert specific_template_exists?("templates/template.rxml")
    assert !specific_template_exists?("templates/template.rpdf")
    assert !specific_template_exists?("templates/non_existing_template")
  end
  
  it "convert action options for generic" do
    @managed_views = ['new']
    options = {:action=>"new", :id=>"1"}
    convert_action_options(options)
    assert_equal({:template=>generic_view("new"), :id=>"1"}, options)
  end

  it "convert action options for specific" do
    @managed_partials = ['new']
    options = {:action=>"new", :id=>"1"}
    convert_action_options(options)
    assert_equal({:action=>"new", :id=>"1"}, options)
  end
  
  # partials are view/controller specific and are tested separately

end
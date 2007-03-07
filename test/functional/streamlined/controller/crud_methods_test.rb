require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/controller/crud_methods'

class Streamlined::Controller::RenderMethodsTest < Test::Unit::TestCase
  include Streamlined::Controller::CrudMethods
  include FlexMock::TestCase
  
  # begin stub methods
  # end stub methods
  
  
  def test_default_options
    self.default_order_options = {:foo=>:bar}
    assert_equal({:foo=>:bar}, order_options)
  end
  
  def test_no_options
    assert_equal({}, order_options)
  end
  
  def test_ar_options
    @page_options = PageOptions.new(:sort_order=>"ASC",
    :sort_column=>"first_name")
    @model = Person
    assert_equal({:order=>"first_name ASC"}, order_options)
  end

  # TODO: non ar_options should go away
  def test_ar_options
    @page_options = PageOptions.new(:sort_order=>"ASC",
    :sort_column=>"widget")
    @model = Person
    # assert_equal({:order=>"widget ASC"}, order_options)
    assert_equal({:dir=>"ASC", :non_ar_column=>"widget"}, order_options)
  end
end
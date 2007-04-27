require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/controller/crud_methods'

class Streamlined::Controller::CrudMethodsTest < Test::Unit::TestCase
  include Streamlined::Controller::CrudMethods
  attr_accessor :model, :streamlined_request_context
  delegates *Streamlined::Context::RequestContext::DELEGATES
  
  def test_helper_delegates_are_private
    assert_has_private_methods self, :pagination
  end
  
  def test_default_options
    @streamlined_request_context = Streamlined::Context::RequestContext.new
    self.default_order_options = {:foo=>:bar}
    assert_equal({:foo=>:bar}, order_options)
  end
  
  def test_no_options
    @streamlined_request_context = Streamlined::Context::RequestContext.new
    assert_equal({}, order_options)
  end
  
  def test_ar_options
    @streamlined_request_context = Streamlined::Context::RequestContext.new(:sort_order=>"ASC",
    :sort_column=>"first_name")
    self.model = Person
    assert_equal({:order=>"first_name ASC"}, order_options)
  end

  # TODO: non ar_options should go away
  def test_non_ar_options
    @streamlined_request_context = Streamlined::Context::RequestContext.new(:sort_order=>"ASC",
    :sort_column=>"widget")
    self.model = Person
    # assert_equal({:order=>"widget ASC"}, order_options)
    assert_equal({:dir=>"ASC", :non_ar_column=>"widget"}, order_options)
  end
  
  def test_sort_models
    joe, frank, ted = models = build_models('Joe', 'Frank', 'Ted')
    sort_models(models, :fname)
    assert_equal [frank, joe, ted], models
  end
  
  def test_sort_models_with_nil_value
    joe, frank, nada = models = build_models('Joe', 'Frank', nil)
    sort_models(models, :fname)
    assert_equal [nada, frank, joe], models
  end
  
  def build_models(*names)
    names.collect { |n| flexmock(:fname => n) }
  end
end
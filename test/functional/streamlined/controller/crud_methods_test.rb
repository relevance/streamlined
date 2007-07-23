require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/controller/crud_methods'
require 'streamlined/controller/filter_methods'

class Streamlined::Controller::CrudMethodsTest < Test::Unit::TestCase
  include Streamlined::Controller::CrudMethods
  include Streamlined::Controller::FilterMethods
  attr_accessor :model, :streamlined_request_context
  delegates *Streamlined::Context::RequestContext::DELEGATES
  
  def test_helper_delegates_are_private
    assert_has_private_methods self, :pagination
  end
  
  def test_default_options
    @streamlined_request_context = Streamlined::Context::RequestContext.new
    @streamlined_controller_context = Streamlined::Context::ControllerContext.new
    @streamlined_controller_context.model_name = 'Person'
    @streamlined_controller_context.model_ui.default_order_options('first_name ASC')
    assert_equal({:order => 'first_name ASC'}, order_options)
  end
  
  def test_no_options
    @streamlined_controller_context = Streamlined::Context::ControllerContext.new
    @streamlined_controller_context.model_name = 'Author'
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
  
  def test_filter_options_with_no_filter
    @streamlined_controller_context = Streamlined::Context::ControllerContext.new
    @streamlined_controller_context.model_name = 'Author'
    @streamlined_request_context = Streamlined::Context::RequestContext.new
    assert_equal({}, filter_options)
  end

  def test_filter_options_with_simple_filter
    str = "data"
    @streamlined_controller_context = Streamlined::Context::ControllerContext.new
    @streamlined_controller_context.model_name = 'Person'
    @streamlined_request_context = Streamlined::Context::RequestContext.new(:filter=>"#{str}")
    assert_equal({:conditions=>"people.first_name LIKE '%#{str}%' OR people.last_name LIKE '%#{str}%'", :include=>[]}, filter_options)
  end
  
  def filter_setup(conditions_string)
    @controller = PeopleController.new
    # Took a while to find this, setting layout=false was not good enough
    class <<@controller
      def active_layout
        false
      end
    end
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller.send :initialize_template_class, @response
    @controller.assign_shortcuts(@request, @response)

    @streamlined_controller_context = Streamlined::Context::ControllerContext.new
    @streamlined_controller_context.model_name = 'Person'
    @streamlined_request_context = Streamlined::Context::RequestContext.new(:advanced_filter=>"#{conditions_string}")

  end

  def test_filter_options_with_advanced_filter_expired
    str = "data"
    conditions_string = "people.first_name like ?,%#{str}%"

    filter_setup(conditions_string)
    session[:num_filters] = nil
    assert_equal({}, filter_options)
  end

  def test_filter_options_with_advanced_filter
    str = "data"
    conditions_string = "people.first_name like ?,%#{str}%"
    conditions        = ["people.first_name like ?", "%#{str}%"]

    filter_setup(conditions_string)
    session[:num_filters] = 1
    assert_equal({:conditions=>conditions}, filter_options)
  end

  def test_filter_options_with_advanced_filter_and_include
    str = "data"
    conditions_string = "people.first_name like ?,%#{str}%"
    conditions        = ["people.first_name like ?", "%#{str}%"]

    filter_setup(conditions_string)

    session[:num_filters] = 1
    includes = ["people", "others"]
    session[:include] = includes

    assert_equal({:conditions=>conditions, :include=>includes}, filter_options)
  end

  def test_filter_options_with_advanced_filter_with_nil
    str = "data"
    conditions_string = "people.first_name like ? and people.last_name is ?,%#{str}%,nil"
    conditions        = ["people.first_name like ? and people.last_name is ?", "%#{str}%", nil]

    filter_setup(conditions_string)

    session[:num_filters] = 1
    assert_equal({:conditions=>conditions}, filter_options)
  end

end
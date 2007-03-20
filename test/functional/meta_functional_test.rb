require File.join(File.dirname(__FILE__), '../test_functional_helper')
require 'streamlined/controller'
require 'streamlined/ui'
require 'streamlined/functional_tests'

class MetaFunctionalTest < Test::Unit::TestCase
  fixtures :people
  include Streamlined::FunctionalTests
  def setup
    @controller = PeopleController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    self.model_class = Person
    self.relevance_crud_fixture = :justin
    self.form_fields = {:input=>[:first_name, :last_name]}
  end
end
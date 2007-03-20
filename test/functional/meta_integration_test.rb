require File.join(File.dirname(__FILE__), '../test_functional_helper')
require 'streamlined/controller'
require 'streamlined/ui'
require 'streamlined/integration_tests'
require 'action_controller/integration'

class MetaIntegrationTest < ActionController::IntegrationTest
  # TODO: need some way to load routes
  # fixtures :people
  # include Streamlined::IntegrationTests
  # def setup
  #   setup_routes
  #   self.model_class = Person
  #   self.relevance_crud_fixture = :justin
  #   self.form_fields = {:input=>[:first_name, :last_name]}
  #   get '/people'
  # end
  
  def test_truth
    
  end
end
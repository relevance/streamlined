base = File.dirname(__FILE__)
require File.join(base, 'test_helper')
Dir.glob("#{base}/fixtures/*.rb") do |file|
  require file
end

require File.join(base, 'ar_helper')
require 'active_record/fixtures'

class Test::Unit::TestCase
  self.fixture_path = File.dirname(__FILE__) + "/fixtures/"
  self.use_instantiated_fixtures = false
  self.use_transactional_fixtures = true

  def create_fixtures(*table_names, &block)
    Fixtures.create_fixtures(self.class.fixture_path, table_names, {}, &block)
  end

  def setup_routes
    ActionController::Routing::Routes.draw do |map|
      map.connect ':controller/:action/:id.:format'
      map.connect ':controller/:action/:id'
    end    
    ActionController::Routing.use_controllers! %w(people)
  end
  
  def stock_controller_and_view
    setup_routes
    @controller = PeopleController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @item = Struct.new(:id).new(1)
    get 'index'
    @view = @response.template
  end
end

# Monkey patching ActionView. This sucks, but I got tired of trying to
# find how to get the base_path set.
class ActionView::Base
  def initialize(base_path = nil, assigns_for_first_render = {}, controller = nil)#:nodoc:
    @base_path, @assigns = base_path, assigns_for_first_render
    @assigns_added = nil
    @controller = controller
    @logger = controller && controller.logger 
    @base_path = File.join(RAILS_ROOT, "app/views")
  end
end


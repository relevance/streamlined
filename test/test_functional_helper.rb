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
  
  def stock_controller_and_view
    @controller = PeopleController.new
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @item = Struct.new(:id).new(1)
    get 'index'
    @view = @response.template
  end
end


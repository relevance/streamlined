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
end


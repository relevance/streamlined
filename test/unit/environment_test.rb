require File.join(File.dirname(__FILE__), '/../test_helper')

class StreamlinedEnvironmentTest < Test::Unit::TestCase
  
  def test_pagination_is_available
    assert defined?(ActionController::Pagination) 
  end
end
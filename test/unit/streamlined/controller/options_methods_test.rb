require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/controller/options_methods'

class Streamlined::Controller::OptionsMethodsTest < Test::Unit::TestCase
  include Streamlined::Controller::OptionsMethods
  
  def test_count_or_find_options_with_empty_hash
    mock_count_or_find_options({})
    assert_equal({}, count_or_find_options)
  end
  
  def test_count_or_find_options_with_strings
    mock_count_or_find_options(:conditions => "foo")
    assert_equal({:conditions => "foo"}, count_or_find_options)
  end
  
  def test_count_or_find_options_with_method_symbols
    mock_count_or_find_options(:conditions => :foo)
    flexmock(self).should_receive(:foo => "foo").once
    assert_equal({:conditions => "foo"}, count_or_find_options)
  end
  
  private
  def mock_count_or_find_options(options)
    flexmock(self.class).should_receive(:count_or_find_options => options).once
  end
end
require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/helpers/filter_helper'

class Streamlined::FilterHelperTest < Test::Unit::TestCase
  include Streamlined::Helpers::FilterHelper

  def test_advanced_filtering_defaults_to_false
    assert !advanced_filtering
  end

end
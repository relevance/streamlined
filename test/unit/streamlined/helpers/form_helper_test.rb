require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/helpers/form_helper'

class Streamlined::FormHelperTest < Test::Unit::TestCase
  include Streamlined::Helpers::FormHelper
  
  def test_unassigned_if_allowed
    assert_equal "<option value='nil' selected>Unassigned</option>", unassigned_if_allowed(nil, nil, nil)
    # TODO: more tests needed here
  end
end
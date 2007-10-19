require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/helpers/link_helper'

class TestLibraryFileName < Test::Unit::TestCase
  include Streamlined::Helpers::LinkHelper

  def test_truth
    assert true
  end

end
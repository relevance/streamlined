require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/helpers/link_helper'

class TestLibraryFileName < Test::Unit::TestCase    
  include Streamlined::Helpers::LinkHelper
  
  def test_export_link      
    flexmock(self).should_receive("url_for").with(:format => :a_format).and_return("url/")
    assert_equal "Streamlined.Exporter.export_to('url/')", export_link(:a_format)
  end
end
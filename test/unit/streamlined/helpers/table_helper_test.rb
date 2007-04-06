require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/helpers/table_helper'

class Streamlined::TableHelperTest < Test::Unit::TestCase
  include Streamlined::Helpers::TableHelper
  attr_accessor :model_ui
  
  def test_streamlined_filter
    @model_ui = Struct.new(:table_filter).new(true)
    assert_equal "<form>Filter:  <input type='text' id='streamlined_filter_term'></form>", streamlined_filter
    @model_ui.table_filter = false
    assert_equal "", streamlined_filter
  end
  
  

end
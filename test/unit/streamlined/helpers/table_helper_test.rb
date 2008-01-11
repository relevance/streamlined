require File.join(File.dirname(__FILE__), '../../../test_helper')
require 'streamlined/helpers/table_helper'

describe "Streamlined::TableHelper" do
  include Streamlined::Helpers::TableHelper
  attr_accessor :model_ui
  
  it "streamlined filter" do
    @model_ui = Struct.new(:table_filter).new(true)
    assert_equal "<div><form><label for='streamlined_filter_term'>Filter:</label>  <input type='text' name='streamlined_filter_term' id='streamlined_filter_term'></form></div>", 
                 streamlined_filter
    @model_ui.table_filter = false
    assert_equal "", streamlined_filter
  end
  
  

end
require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/helpers/link_helper'

class Streamlined::Helpers::TableHelperTest < Test::Unit::TestCase
  fixtures :people
  def setup
    stock_controller_and_view
  end

  def test_no_buttons
    @view.model_ui.table_row_buttons false
    assert_equal "", @view.streamlined_table_row_button_header
    assert_equal "", @view.streamlined_table_row_buttons(people(:justin))
  end
  
  def test_buttons
    assert_equal "<th>&nbsp;</th>", @view.streamlined_table_row_button_header
    # TODO: fill in this test once the link helpers use unobtrusive JavaScript
    # assert_equal "", @view.streamlined_table_row_buttons(people(:justin))
  end
  
end
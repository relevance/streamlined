require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/helpers/link_helper'

class Streamlined::Helpers::TableHelperFunctionalTest < Test::Unit::TestCase
  fixtures :people
  def setup
    stock_controller_and_view
  end

  def test_no_buttons
    @view.send(:model_ui).table_row_buttons false
    assert_equal "", @view.streamlined_table_row_button_header
    assert_equal "", @view.streamlined_table_row_buttons(people(:justin))
  end
  
  def test_buttons
    assert_equal "<th>&nbsp;</th>", @view.streamlined_table_row_button_header
    item = people(:justin)
    assert_equal "<td>#{@view.link_to_show_model(item)} #{@view.link_to_edit_model(item)}#{@view.quick_delete_button(item)}</td>", @view.streamlined_table_row_buttons(item)
  end
  
  def test_no_quick_delete_button
    @view.send(:model_ui).table_row_buttons true    
    @view.send(:model_ui).quick_delete_button false
    assert_equal "<th>&nbsp;</th>", @view.streamlined_table_row_button_header
    item = people(:justin)
    assert_equal "<td>#{@view.link_to_show_model(item)} #{@view.link_to_edit_model(item)}</td>", @view.streamlined_table_row_buttons(item)
  end
  
end
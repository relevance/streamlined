module Streamlined::Helpers::TableHelper
  def streamlined_table_row_button_header
    model_ui.table_row_buttons ? "<th>&nbsp;</th>" : ""
  end
  
  def streamlined_table_row_buttons(item)
    if model_ui.table_row_buttons
      "<td>#{link_to_show_model(item)} #{link_to_edit_model(item)}#{quick_delete_button(item)}</td>"
    else
      ""
    end
  end
  
  def quick_delete_button(item)
    if model_ui.quick_delete_button
      " #{link_to_delete_model(item)}"
    else
      ""
    end
  end
  
  def streamlined_filter
    if model_ui.table_filter
  	  "<form>Filter:  <input type='text' id='streamlined_filter_term'></form>"
    else
      ""
    end
  end
end
module Streamlined::Helpers::TableHelper
  def streamlined_table_row_button_header
    @model_ui.table_row_buttons ? "<th>&nbsp;</th>" : ""
  end
  
  def streamlined_table_row_buttons(item)
    if @model_ui.table_row_buttons
      "<td>#{link_to_show_model(item)} #{link_to_edit_model(item)} #{link_to_delete_model(item)}</td>"      
    else
      ""
    end
  end
end
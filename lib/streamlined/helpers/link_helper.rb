module Streamlined::Helpers::LinkHelper
  def link_to_new_model
    link_to_function image_tag('streamlined/add_16.png', 
        {:alt => "New #{@model_name}", :title => "New #{@model_name}", :border => '0'}),          
        "Streamlined.Windows.open_local_window_from_url('New', '#{url_for(:action => 'new')}')",
        :href => url_for(:action=>'new')
  end
  # TODO add :hrefs options like above (dry and generalize...)
  def link_to_xml_export
    link_to_function(image_tag('streamlined/export_16.png', 
        {:alt => "Export XML", :title => "Export XML", :border => '0'}),
        "Streamlined.Exporter.export_to('#{url_for(:action => 'export_to_xml')}')")    
  end
  def link_to_csv_export
    link_to_function(image_tag('streamlined/save_16.png', 
        {:alt => "Export CSV", :title => "Export CSV", :border => 0}),
        "Streamlined.Exporter.export_to('#{url_for(:action => 'export_to_csv')}')")
  end
  def link_to_next_page
    link_to_function image_tag('streamlined/control-reverse_16.png', 
        {:id => 'previous_page', :alt => 'Previous Page', :style => @streamlined_item_pages != [] && @streamlined_item_pages.current.previous ? "" : "display: none;", :title => 'Previous Page', :border => '0'}), 
        "Streamlined.PageOptions.previousPage()"    
  end
  def link_to_previous_page
    link_to_function image_tag('streamlined/control-forward_16.png', 
        {:id => 'next_page', :alt => 'Next Page', :style => @streamlined_item_pages != [] && @streamlined_item_pages.current.next ? "" : "display: none;", :title => 'Next Page', :border => '0'}),   
        "Streamlined.PageOptions.nextPage()"  
  end
end

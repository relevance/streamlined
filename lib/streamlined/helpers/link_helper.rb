module Streamlined::Helpers::LinkHelper
  def guess_show_link_for(model)
    case model
      when Enumerable
        "(multiple)"
      when ActiveRecord::Base
        link_to model.streamlined_name, :controller=>model.class.name.pluralize, :action=>"show", :id=>model
      when nil
        "(unassigned)"
      else 
        "(unknown)"
    end
  end
  # TODO: add unobtrusive JavaScript for:
  # Streamlined.Windows.open_local_window_from_url('New', '#{url_for(:action => 'new')}'
  def link_to_new_model
    link_to(image_tag('streamlined/add_16.png', 
        {:alt => "New #{model_name}", :title => "New #{model_name}", :border => '0'}),          
        :action => 'new') unless model_ui.read_only
  end

  def link_to_show_model(item)
    link_to(image_tag('streamlined/search_16.png', 
        {:alt => "Show #{model_name}", :title => "Show #{model_name}", :border => '0'}),          
        :action => 'show', :id=>item)
  end

  def link_to_edit_model(item)
    link_to(image_tag('streamlined/edit_16.png', 
        {:alt => "Edit #{model_name}", :title => "Edit #{model_name}", :border => '0'}),          
        :action => 'edit', :id=>item) unless model_ui.read_only
  end

  # replaced by wrap_with_link, below, and see comment
  # def text_link_to_edit_model(column,item)
  #   link_to_function(h(item.send(column.name)),   
  #       "Streamlined.Windows.open_local_window_from_url('Edit', '#{url_for(:action => 'edit', :id => item.id)}', #{item.id})",
  #       :href => url_for(:action=>"edit", :id=>id))
  # end
  
  # TODO:
  # 1. Kill all the JavaScript code generation in links
  # 2. Move all the degradable module stuff here
  # 3. Add JavaScript to the page to make links into window creation links
  def wrap_with_link(link_args)
    link_to(yield,link_args)
  end

  def link_to_delete_model(item)
    id = item.id
    link_to image_tag('streamlined/delete_16.png', {:alt => 'Destroy', :title => 'Destroy', :border => '0'}), 
        {:action => 'destroy', :id => item }, 
        :confirm => 'Are you sure?', :method => "post"    
  end
  # TODO add :hrefs options like above (dry and generalize...)
  def link_to_xml_export
    link_to_function(image_tag('streamlined/export_16.png', 
        {:alt => "Export XML", :title => "Export XML", :border => '0'}),
        "Streamlined.Exporter.export_to('#{url_for(:format => 'xml')}')")    
  end
  def link_to_csv_export
    link_to_function(image_tag('streamlined/save_16.png', 
        {:alt => "Export CSV", :title => "Export CSV", :border => 0}),
        "Streamlined.Exporter.export_to('#{url_for(:format => 'csv')}')")
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



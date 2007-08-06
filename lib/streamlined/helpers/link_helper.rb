# Helpers for creating links. Many of these links have additional functionality, implied by
# CSS classes. Streamlined.js picks up these CSS classes and adds capabilities.

# TODO: This class is almost identical to WindowLinkHelper. The duplication should be refactored out.
module Streamlined::Helpers::LinkHelper
  def guess_show_link_for(model)
    case model
      when Enumerable
        "(multiple)"
      when ActiveRecord::Base
        link_to(model.streamlined_name,
          :controller => model.class.name.underscore.pluralize,
          :action => "show", :id => model)
      when nil
        "(unassigned)"
      else 
        "(unknown)"
    end
  end
  
  # Clicking on the +link+ will toggle visibility of the DOM ID +element+.
  def link_to_toggler(link, element)
    link_to(link, "\##{element}", :class=>"sl_toggler")
  end
  
  # TODO: add unobtrusive JavaScript for:
  # Streamlined.Windows.open_local_window_from_url('New', '#{url_for(:action => 'new')}'
  def link_to_new_model
    link_to(image_tag('streamlined/add_16.png', 
        {:alt => "New #{model_name.titleize}", :title => "New #{model_name.titleize}", :border => '0'}),          
        :action => 'new') unless model_ui.read_only || !model_ui.quick_new_button
  end

  def link_to_show_model(item)
    link_to(image_tag('streamlined/search_16.png', 
        {:alt => "Show #{model_name.titleize}", :title => "Show #{model_name.titleize}", :border => '0'}),          
        :action => 'show', :id=>item)
  end

  def link_to_edit_model(item)
    link_to(image_tag('streamlined/edit_16.png', 
        {:alt => "Edit #{model_name.titleize}", :title => "Edit #{model_name.titleize}", :border => '0'}),          
        :action => 'edit', :id=>item) unless model_ui.read_only
  end

  # replaced by wrap_with_link, below, and see comment
  # def text_link_to_edit_model(column,item)
  #   link_to_function(h(item.send(column.name)),   
  #       "Streamlined.Windows.open_local_window_from_url('Edit', '#{url_for(:action => 'edit', :id => item.id)}', #{item.id})",
  #       :href => url_for(:action=>"edit", :id=>id))
  # end
  
  # TODO:
  # 1. Move all the degradable module stuff here
  # 2. Add JavaScript to the page to make links into window creation links
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
    link_to_export(:xml, :export)
  end
  def link_to_json_export    
    link_to_export(:json, :export)
  end
  def link_to_yaml_export    
    link_to_export(:yaml, :export)
  end
  def link_to_csv_export
    link_to_export(:csv, :save)
  end
  def link_to_next_page
    link_to_function image_tag('streamlined/control-forward_16.png', 
        {:id => 'next_page', :alt => 'Next Page', :style => @streamlined_item_pages != [] && @streamlined_item_pages.current.next ? "" : "display: none;", :title => 'Next Page', :border => '0'}),   
        "Streamlined.PageOptions.nextPage()"
  end
  def link_to_previous_page
    link_to_function image_tag('streamlined/control-reverse_16.png', 
        {:id => 'previous_page', :alt => 'Previous Page', :style => @streamlined_item_pages != [] && @streamlined_item_pages.current.previous ? "" : "display: none;", :title => 'Previous Page', :border => '0'}), 
        "Streamlined.PageOptions.previousPage()"
  end
  
  def link_to_export(format, image_type)
    return '' unless model_ui.displays_exporter?(format)
    title = "Export #{format.to_s.upcase}"
    link_to_function(image_tag("streamlined/#{image_type}_16.png", 
        {:alt => title, :title => title, :border => 0}),
        export_onclick(format))
  end           
  
  def export_onclick(format)
    "Streamlined.Exporter.export_to('#{url_for(:format => format)}')"
  end
end
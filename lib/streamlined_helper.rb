# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com
#
# The methods here are available to all Streamlined views.  
module StreamlinedHelper
  
  # Given an image file, checks to see if the image exists in the filesystem.
  # If it does, display the image. If not, suppress the generation of the image
  # tag.  Used to add model-specific icons to the UI.  If the icon does not
  # exist, ensures no broken image tag or alternate text is rendered to the page.
  def image_tag_if_exists(image, options = {})  
    image_tag(image, options) if(File.exist?File.join(RAILS_ROOT, 'public', 'images', image)) 
  end
  
  # TODO: move this onto mixin that mixes into AR Column and into Streamlined Column
  # column_sort_image(page_options.sort_column, column.human_name, page_options.sort_order)
  def column_sort_image(page_options, column)
    if page_options.sort_column == column.human_name
      direction = page_options.ascending? ? 'up' : 'down'
      image_tag("streamlined/arrow-#{direction}_16.png", {:height => '10px', :border => 0})
    else
      ''
    end
  end
  
  def popup_events_for_item(item, column, model_ui)
    if model_ui.popup_columns.include?(column.name.to_sym)
      %{onmouseover="Streamlined.Popup.show('#{url_for(:action => 'popup', :id => item.id)}');" onmouseout="nd();"} 
    end
  end
  
  
  # Creates the id for the div containing a given relationship. 
  def relationship_div_id(relationship, item, in_window = false)
    "#{@model_ui.relationships[relationship.name].view_def.id_fragment}::#{relationship.name}::#{item.id}::#{relationship.class_name}#{'::win' if in_window}"
  end
  
  # If the validation_reflection plugin is available and working properly, check to see if the given 
  # relationship allows for a nil assignment.  If so, return the "Unassigned" option.  Otherwise, return nothing.
  def unassigned_if_allowed(klass, relationship, items)
    return "<option value='nil' #{'selected' unless items}>Unassigned</option>" unless klass.respond_to?("reflect_on_validations_for")
    require 'facet/module/alias_method_chain' unless Module.respond_to?('alias_method_chain')
    return "<option value='nil' #{'selected' unless items}>Unassigned</option>" unless Module.respond_to?('alias_method_chain')
    
    if klass.reflect_on_validations_for(relationship).collect {|v| v.macro}.include?(:validates_associated)
      return ""
    else
      return "<option value='nil' #{'selected' unless items}>Unassigned</option>"
    end
  end
  
  # Given a model and a controller, finds all the columns that are currently slated to be shown in the list view.
  def show_columns_for_model(klass, klass_ui, controller)    
    results = current_show_columns(klass, klass_ui, controller).collect {|c| klass_ui.all_columns.find {|col| col.name == c}}
    results.reject! {|c| c == nil}
    return results
    # return klass.columns.select {|c| current_show_columns(klass, klass_ui, controller).include?(c.name)}
  end
  
  # Given a model and a controller, finds all the columns that are currently NOT slated to be shown in the list view.
  def hide_columns_for_model(klass, klass_ui, controller)
    return klass_ui.all_columns.reject {|c| current_show_columns(klass, klass_ui, controller).include?(c.name)}
  end
  
  
  # Alternative to the default render method of ApplicationHelper.  Attempts to 
  # perform the render through the standard #render method. If that fails, 
  # ensure that the requested view or partial is managed by Streamlined, then 
  # render it from app/views/streamlined/generic_views.
  def streamlined_render(options = nil, deprecated_status = nil, &block)
    begin
      render(options, deprecated_status, &block)
    rescue ActionView::TemplateError => ex 
      raise ex
    rescue Exception => ex
      if options
        if options[:partial] && @managed_partials.include?(options[:partial])
          options[:partial] = controller.generic_view(options[:partial])
          render(options, deprecated_status, &block)
        else
          raise ex
        end
      else
        view_name = default_template_name.split("/")[-1]
        render(:template => StreamlinedController.generic_view(view_name))
      end
    end
  end
  
  # Given a template name, determines the precise location of the file to be used: model-specific view folders, or generic views
  def render_path(template, options = {:partial => true, :con_name => nil})
     options[:con_name] ||= controller_name
     template_file = "_#{template}" if options[:partial]
     File.exist?(File.join(RAILS_ROOT, 'app', 'views', options[:con_name], template_file + ".rhtml")) ? template : "../../vendor/plugins/streamlined/templates/generic_views/#{template}"
  end
  
  # Create auto-discovery Atom link
  def streamlined_auto_discovery_link_tag()
        return if @syndication_type.nil? || @syndication_actions.nil?
  
        if @syndication_actions.include? params[:action]
            "<link rel=\"alternate\" type=\"application/#{@syndication_type.downcase}+xml\" title=\"#{@syndication_type.upcase}\" href=\"#{params[:action]}/xml\" />"
        end
  end
  
  def streamlined_column_html( object, column )
      begin
          column_as_string = column.respond_to?( :name ) ? object.send( column.name.to_sym ) : ""

          return column_as_string if column.class == Streamlined::Column

          return html_escape( column_as_string )
      rescue
          return ""
      end
  end
  
  def generic_view(template)
    "../../vendor/plugins/streamlined/templates/generic_views/#{template}"
  end
  
  private

   def current_show_columns(klass, klass_ui, controller)
     controller = controller.to_sym
     session[:current_user] ? pref = session[:current_user].preferences : pref = nil
       
     if pref && pref.page_columns && pref.page_columns.instance_of?(Hash) && pref.page_columns[controller]
       current = pref.page_columns[controller]
     else    
       current = klass_ui.user_default_columns_for_display.collect {|c| c.name}
     end 
     return current
   end
end
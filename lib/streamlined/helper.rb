# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com
#
# The methods here are available to all Streamlined views.

module Streamlined; end
module Streamlined; module Helpers; end; end

require 'relevance/dsl'
require 'streamlined/helpers/link_helper'
require 'streamlined/helpers/layout_helper'
require 'streamlined/helpers/table_helper'
  
module Streamlined::Helper
  include Streamlined::Helpers::TableHelper
  include Streamlined::Helpers::LinkHelper
  include Streamlined::Helpers::LayoutHelper
  
  # include this last
  include Streamlined::View::RenderMethods
  
  def self.included(includer)
    includer.class_eval do
      attr_reader :streamlined_controller_context, :streamlined_request_context
      delegates *Streamlined::Context::ControllerContext::DELEGATES
    end
  end
  
  # Given an image file, checks to see if the image exists in the filesystem.
  # If it does, display the image. If not, suppress the generation of the image
  # tag.  Used to add model-specific icons to the UI.  If the icon does not
  # exist, ensures no broken image tag or alternate text is rendered to the page.
  def image_tag_if_exists(image, options = {})  
    image_tag(image, options) if(File.exist?File.join(RAILS_ROOT, 'public', 'images', image)) 
  end
  
  # invisible links are plucked out by unobtrusive JavaScript to add functionality
  def invisible_link_to(options = {}, html_options={}, *parms)
    link_to('', options, html_options.merge(:style=>"display:none;"), *parms)    
  end
 
#  TODO: look for spans with a popup class and layer in the JavaScript  
#  def popup_events_for_item(item, column, model_ui)
#    if model_ui.popup_columns.include?(column.name.to_sym)
#      %{onmouseover="Streamlined.Popup.show('#{url_for(:action => 'popup', :id => item.id)}');" onmouseout="nd();"} 
#    end
#  end
  
  # Creates the id for the div containing a given relationship. 
  def relationship_div_id(relationship, item, in_window = false)
    "#{model_ui.relationships[relationship.name].edit_view.id_fragment}::#{relationship.name}::#{item.id}::#{relationship.class_name}#{'::win' if in_window}"
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
  def list_columns_for_model(klass, klass_ui, controller)    
    results = current_list_columns(klass, klass_ui, controller).collect {|c| klass_ui.all_columns.find {|col| col.name == c}}
    results.reject! {|c| c == nil}
    return results
    # return klass.columns.select {|c| current_list_columns(klass, klass_ui, controller).include?(c.name)}
  end
  
  # Given a model and a controller, finds all the columns that are currently NOT slated to be shown in the list view.
  def hide_columns_for_model(klass, klass_ui, controller)
    return klass_ui.all_columns.reject {|c| current_list_columns(klass, klass_ui, controller).include?(c.name)}
  end
  
  
  # Given a template name, determines the precise location of the file to be used: model-specific view folders, or generic views
  delegate :generic_view, :to=>:controller
  
  def streamlined_column_html( object, column )
      begin
          column_as_string = column.respond_to?( :name ) ? object.send( column.name.to_sym ) : ""

          return column_as_string if column.class == Streamlined::Column

          return html_escape( column_as_string )
      rescue
          return ""
      end
  end
  
  private

   def current_list_columns(klass, klass_ui, controller)
     controller = controller.to_sym
     session[:current_user] ? pref = session[:current_user].preferences : pref = nil
       
     if pref && pref.page_columns && pref.page_columns.instance_of?(Hash) && pref.page_columns[controller]
       current = pref.page_columns[controller]
     else    
       current = klass_ui.list_columns.collect {|c| c.name}
     end 
     return current
   end
end
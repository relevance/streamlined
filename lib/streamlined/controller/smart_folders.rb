module Streamlined::Controller::SmartFolders
  # TODO: should this be the list method on a SmartFolderController?
  def list_from_smart_folder( partial = 'list' )
     @smart_folders = find_smart_folders
     @smart_folder = SmartFolder.find(params[:smart_folder_id])

     model_pages, models = [], @smart_folder.members

     self.instance_variable_set("@#{Inflector.underscore(model_name)}_pages", model_pages)
     self.instance_variable_set("@#{Inflector.tableize(model_name)}", models)
     @streamlined_items = models
     @streamlined_item_pages = model_pages
     @model_count = models.size

  #        flash[:notice] = "Found #{@model_count} #{(@model_count == 1) ? model_name : model_name.pluralize}" if filter && filter != ''
     # if request.xhr?
  #        @con_name = controller_name
  #        render :update do |page|
  #            page << "if($('notice')) {Element.hide('notice');} if($('notice-error')) {Element.hide('notice-error');} if($('notice-empty')) {Element.hide('notice-empty');}"
  #            page.show 'notice-info'
  #            page.replace_html "notice-info", @controller.list_notice_info  
  #            page.replace_html "#{model_underscore}_list", :partial => render_path( partial, :partial => true, :con_name => @con_name )
  #            ##edit_link_html = link_to_function( '(edit)', "Streamlined.Windows.open_local_window_from_url('Smart Groups', '#{url_for(:controller => 'smart_folders', :action => 'edit', :id => @smart_folder.id, :target_controller => 'campaigns', :target_class => model_name || target_class)}', null, null, {title: 'Edit Smart Group', closable: false, width:840, height:480 })" )
  #            page.replace_html "breadcrumbs_text", neocast_breadcrumbs_text_innerhtml( :model => model_name, :text => [ model_name.pluralize, "Smart Group", @smart_folder.name ] )
  #            page.visual_effect :highlight, 'breadcrumbs'
  #        end
  #    end
   render :partial => 'list' if request.xhr?
  end

  private

  # def list_notice_info
  #  "Found #{@model_count} #{ ( (@model_count == 1) ? model_name : model_name.pluralize ).downcase }"
  # end


  def find_smart_folders
    begin
      return [] if current_user.nil? 
      current_user.smart_folders.find(:all, :conditions => ['target_class = ?', model_name]) || []
    rescue
      return []
    end
  end
  
end
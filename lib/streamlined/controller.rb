# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com

# This is not in init.rb because constants created there seem to get blown away! Yuck.
raise "Must have a RAILS_ROOT" unless RAILS_ROOT
STREAMLINED_ROOT = File.join(File.dirname(__FILE__), "../..")
STREAMLINED_GENERIC_VIEW_ROOT = 
File.join(Pathname.new(STREAMLINED_ROOT).relative_path_from(Pathname.new(RAILS_ROOT+"/app/views")).to_s,
                       "/templates/generic_views")

module Streamlined; end
module Streamlined::Controller 
  def self.included(base)
    base.extend(ClassMethods)              
  end
end

require 'streamlined/controller/crud_methods'
require 'streamlined/controller/render_methods'

module Streamlined::Controller::InstanceMethods
  include Streamlined::Controller::CrudMethods
  include Streamlined::Controller::RenderMethods
  def index
    list
    render :action => 'list'
  end
  
   def list_notice_info
    "Found #{@model_count} #{ ( (@model_count == 1) ? @model_name : @model_name.pluralize ).downcase }"
   end

   def list_from_smart_folder( partial = 'list' )
       @smart_folders = find_smart_folders
       @smart_folder = SmartFolder.find(params[:smart_folder_id])

       model_pages, models = [], @smart_folder.members

       self.instance_variable_set("@#{Inflector.underscore(@model_name)}_pages", model_pages)
       self.instance_variable_set("@#{Inflector.tableize(@model_name)}", models)
       @streamlined_items = models
       @streamlined_item_pages = model_pages
       @model_count = models.size

#        flash[:notice] = "Found #{@model_count} #{(@model_count == 1) ? @model_name : @model_name.pluralize}" if @page_options.filter && @page_options.filter != ''
       # if request.xhr?
    #        @con_name = controller_name
    #        render :update do |page|
    #            page << "if($('notice')) {Element.hide('notice');} if($('notice-error')) {Element.hide('notice-error');} if($('notice-empty')) {Element.hide('notice-empty');}"
    #            page.show 'notice-info'
    #            page.replace_html "notice-info", @controller.list_notice_info  
    #            page.replace_html "#{@model_underscore}_list", :partial => render_path( partial, :partial => true, :con_name => @con_name )
    #            ##edit_link_html = link_to_function( '(edit)', "Streamlined.Windows.open_local_window_from_url('Smart Groups', '#{url_for(:controller => 'smart_folders', :action => 'edit', :id => @smart_folder.id, :target_controller => 'campaigns', :target_class => @model_name || target_class)}', null, null, {title: 'Edit Smart Group', closable: false, width:840, height:480 })" )
    #            page.replace_html "breadcrumbs_text", neocast_breadcrumbs_text_innerhtml( :model => @model_name, :text => [ @model_name.pluralize, "Smart Group", @smart_folder.name ] )
    #            page.visual_effect :highlight, 'breadcrumbs'
    #        end
    #    end
     render :partial => 'list' if request.xhr?
   end

   # Opens the search view.  The default is a criteria query view.
   def search
     self.instance = @model.new
     render(:partial => 'search')
   end

   # Executes the search.  The default behavior is to create 
   # a criteria instance of the @model being searched and execute
   # the find_by_criteria method on the @model class.
   def find
     self.instance = @model.new(params[@model_symbol])
     @results = @model.find_by_criteria(instance)
     render(:partial => 'results')
   end

   # Renders the current scoped list of @model instances as an XML document.  For example,
   # if the user is just looking at the #list view, it will render all the existing instances
   # of the @model.  However, if the user has used the filter to narrow the list, export_to_xml
   # will only render the current filter set to XML.
   def export_to_xml
     @headers["Content-Type"] = "text/xml"
     @headers["Content-Disposition"] = "attachment; filename=\"#{Inflector.tableize(@model_name)}_#{Time.now.strftime('%Y%m%d')}.xml\""
     render(:text => @model.find_by_like(@page_options.filter).to_xml)
   end

   # Renders the current scoped list of @model instances as a CSV document.  For example,
   # if the user is just looking at the #list view, it will render all the existing instances
   # of the @model.  However, if the user has used the filter to narrow the list, export_to_csv
   # will only render the current filter set to CSV.
   def export_to_csv
     @headers["Content-Type"] = "text/csv"
     @headers["Content-Disposition"] = "attachment; filename=\"#{Inflector.tableize(@model_name)}_#{Time.now.strftime('%Y%m%d')}.csv\""
     render(:text => @model.find_by_like(@page_options.filter).to_csv(@model.column_names))
   end

   # Opens the relationship +view+ for a given relationship on the @model.  This means
   # replacing the +summary+ view with the expanded +view+, as defined in streamlined_ui 
   # and streamlined_relationships.
   def expand_relationship
     self.instance = @model.find(params[:id])
     rel_type = relationship_for_name(params[:relationship])
     @relationship_name = params[:relationship]
     @root = instance
     set_items_and_all_items(rel_type)
     render(:partial => rel_type.view_def.partial)
   end

   # Closes the expanded relationship +view+ and replaces it with the +summary+ view, 
   # as defined in streamlined_ui and streamlined_relationships.
   def close_relationship
     self.instance = @model.find(params[:id])
     rel_type = relationship_for_name(params[:relationship])
     relationship_name = params[:relationship]
     # klass = Class.class_eval(params[:klass])
#      @klass_ui = Class.class_eval(params[:klass] + "UI")
     relationship = instance.class.reflect_on_all_associations.select {|x| x.name == relationship_name.to_sym}[0]
     @root = instance
     render(:partial => rel_type.summary_def.partial, :locals => {:item => instance, :relationship => relationship, :streamlined_def => rel_type.summary_def})
   end

   # Add new items to the given relationship collection. Used by the #membership view, as 
   # defined in streamlined_relationships.
   def update_relationship
     items = params[:item]
      self.instance = @model.find(params[:id])
      rel_name = params[:rel_name].to_sym
      instance.send(rel_name).clear
      klass = Class.class_eval(params[:klass])
      @klass_ui = Streamlined.get_ui(params[:klass])
      relationship = @model_ui.relationships[rel_name]
      items.each do |id, onoff|
        instance.send(rel_name).push(klass.find(id)) if onoff == 'on'
      end
      instance.save
      if relationship.view_def.respond_to?(:render_on_update)
        @relationship_name = rel_name
        @root = instance
        set_items_and_all_items(relationship, params[:filter])
        render :update do |page|
          relationship.view_def.render_on_update(page, rel_name, params[:id])
        end
      else
        render(:nothing => true)
      end
   end

   # Add new items to the given relationship collection. Used by the #membership view, as 
   # defined in streamlined_relationships.
   def update_n_to_one
    item = params[:item]
    self.instance = @model.find(params[:id])
    rel_name = "#{params[:rel_name]}=".to_sym
    if item == 'nil' || item == nil
      instance.send(rel_name, nil)
    else
      item_parts = item.split("::")
      if item_parts.size == 1
        new_item = Class.class_eval(params[:klass]).find(item)
      else
        new_item = Class.class_eval(item_parts[1]).find(item_parts[0])
      end
      instance.send(rel_name, new_item)
    end
    instance.save
    render(:nothing)
   end

  # Creates the popup window for an item
  def popup
    self.instance = @model.find(params[:id])
    render :partial => 'popup'
  end
       
  def columns
    render(:partial => "columns")
  end

  def reset_columns
    pref = current_user.preferences
    pref.page_columns ||= {}
    current_user.preferences.page_columns.delete( controller_name.to_sym )
    current_user.preferences.save
    current_user.preferences.reload
    render :update do |page|
      page.redirect_to(:action => 'list')
    end
  end

  def save_columns
    cols = params["displaycolumns"].find_all { |col| col unless col.blank? }
    pref = current_user.preferences
    pref.page_columns ||= {}
    current_user.preferences.page_columns[controller_name.to_sym] = cols
    current_user.preferences.save
    current_user.preferences.reload
    render :update do |page|
      page.redirect_to(:action => 'list')
    end
  end
       
  def add_tags
    if Object.const_defined?(:Tag) && params[:new_tags]
      item = @model.find(params[:id])
      tags = params[:new_tags].split(' ')
      @new_tags = []
      tags.each do |tag| 
        unless Tag.find_by_name(tag)
          @new_tags << Tag.create(:name => tag)
        end  
      end
      render :update do |page|
        page['tags_form'].replace_html :partial => 'shared/tags', :locals => {:item => item}
      end
    end
  end
       
  private

  def initialize_page_options
    @page_options = PageOptions.new(params[:page_options])
  end
        
  def initialize_streamlined_values(mod_name = nil)
    if mod_name
      @model_name = mod_name
    else
      @model_name ||= self.class.model_name || Inflector.classify(self.class.controller_name)
    end
    @model = Class.class_eval(@model_name)
    @model_symbol = Inflector.underscore(@model_name).to_sym
    if Object.const_defined?(@model_name + "UI")
      @model_ui = Class.class_eval(@model_name + "UI")
    else
      @model_ui = Streamlined.generic_ui
      @model_ui.model = @model
    end
    @model_table = Inflector.tableize(@model_name)
    @model_underscore = Inflector.underscore(@model_name)
    @page_title = "Manage \#{@model_name.pluralize}"
    @tags = @model.tag_list.split(',') if @model.respond_to? :tag_list
  end

  # rewrite of rails method
  def paginator_and_collection_for(collection_id, options) #:nodoc:
    klass = @model
    # page  = @params[options[:parameter]]
    page = @page_options.page
    count = count_collection_for_pagination(klass, options)
    paginator = ActionController::Pagination::Paginator.new(self, count, options[:per_page], page)
    collection = find_collection_for_pagination(klass, options, paginator)

    return paginator, collection 
  end

  def instance
    self.instance_variable_get("@#{Inflector.underscore(@model_name)}")
  end

  def instance=(value)
    self.instance_variable_set("@#{Inflector.underscore(@model_name)}", value)
    @streamlined_item = value
  end

  def relationship_for_name(rel_name)
    @model_ui.relationships[rel_name.to_sym]
  end

  def set_items_and_all_items(rel_type, item_filter = nil)
     RAILS_DEFAULT_LOGGER.debug("SET_ITEMS_AND_ALL_ITEMS: #{item_filter}")
     @items = instance.send(@relationship_name)
     if rel_type.associables.size == 1
       @klass = Class.class_eval(params[:klass])
       @klass_ui = Streamlined.get_ui(params[:klass])
       if item_filter
         @all_items = @klass.find(:all, :conditions => @klass.conditions_by_like(item_filter))
       else            
         @all_items = @klass.find(:all)
       end
     else
       @all_items = {}
       rel_type.associables.each do |klass|
         if item_filter
           @all_items[klass.name] = klass.find(:all, :conditions => klass.conditions_by_like(item_filter))
         else
           @all_items[klass.name] = klass.find(:all)
         end
       end
     end
  end
        
  def find_smart_folders
    begin
      return [] if current_user.nil? 
      current_user.smart_folders.find(:all, :conditions => ['target_class = ?', @model_name]) || []
    rescue
      return []
    end
  end
end

module Streamlined::Controller::ClassMethods  
  @custom_model_name = nil
    
  def acts_as_streamlined(options = {})
    class_eval <<-EOV
include Streamlined::Controller::InstanceMethods

if defined? AuthenticatedSystem
  include AuthenticatedSystem
  before_filter :login_required  
end
before_filter :initialize_page_options

require_dependencies :ui, Dir["#{RAILS_ROOT}/app/streamlined/*.rb"].collect {|f| f.gsub(".rb", "")}

# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
verify :method => :post, :only => [ :destroy, :create, :update ],
       :redirect_to => { :action => :list }
       
       def initialize_with_streamlined_variables
          if self.class == Streamlined::Controller
              RAILS_DEFAULT_LOGGER.warn("Cannot directly browse the Streamlined framework (/streamlined)")
              raise "Cannot directly browse the Streamlined framework (/streamlined)" 
          end

          begin
            initialize_streamlined_values
            @managed_views = ['list', 'new', 'show', 'edit']
            @managed_partials = ['list', 'form', 'popup', 'tags', 'tag_list', 'columns', 'show_columns', 'hide_columns']                    
            @syndication_type ||= "rss"
            @syndication_actions ||= "list"
            RAILS_DEFAULT_LOGGER.info("@model NAME: #{@model_name}")
            RAILS_DEFAULT_LOGGER.info("@model: #{@model.inspect}")
          rescue Exception => ex
            RAILS_DEFAULT_LOGGER.info("Could not instantiate controller: #{self.class.name}")
            raise ex
          end
        end       
       
alias_method_chain :initialize, :streamlined_variables
EOV
  end
    
  def model_name 
    @custom_model_name || nil
  end
        
  def syndication(options = {})
    @syndication_type = options[:type].nil? ? "rss" : options[:type].to_s
    @syndication_actions = options[:actions].nil? ? "list" : (options[:actions].map &:to_s)
  end
    
  def streamlined_model(mod)
    mod.instance_of?(String) ? @custom_model_name = mod : @custom_model_name = mod.name
  end
end

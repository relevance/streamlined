# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com
require "#{RAILS_ROOT}/app/controllers/application"
module StreamlinedController 
  def self.included(base)
    raise "Cannot extend ApplicationController with acts_as_streamlined: please extend individual controllers." if base.instance_of? ApplicationController
    base.extend(ClassMethods)              
  end
  
  module InstanceMethods
    def index
      list
      render :action => 'list'
    end
    
    
    def generic_view(template)
      self.class.generic_view(template)
    end
    
       # Creates the list of items of the @managed @model class. Default behavior
       # creates an Ajax-enabled table view that paginates in groups of 10.  The 
       # resulting view will use Prototype and XHR to allow the user to page
       # through the @model instances.  
       #
       # If the URL includes the <code>atom=true</code> querystring variable, the
       # action will instead render the Atom feed of all items found for this 
       # @model.
       #
       # If the request came via XHR, the action will render just the list partial,
       # not the entire list view.
       def list
         @smart_folders = find_smart_folders
         @model_ui.pagination ? options = {:per_page => 10} : options = {}
         options.merge! order_options
         if @page_options.filter?
           options.merge! :conditions=>@model.conditions_by_like(@page_options.filter) 
           @model_count = @model.count(:conditions => @model.conditions_by_like(@page_options.filter))
         else
           @model_count = @model.count
         end
         if params[:syndicated]
           if @page_options.filter?
              models = @model.find(:all, :conditions=>@model.conditions_by_like(@page_options.filter))
            else
              models = @model.find(:all)
            end
            @streamlined_items = models
         else
           if @model_ui.pagination
              if options[:non_ar_column]
                 col = options[:non_ar_column]
                 dir = options[:dir]
                 options.delete :non_ar_column
                 options.delete :dir
                 model_pages, models = paginate Inflector.pluralize(@model_class).downcase.to_sym, options
                 models.sort! {|a,b| a.send(col.to_sym) <=> b.send(col.to_sym)}
                 models.reverse! if dir == 'DESC'
               else
                 model_pages, models = paginate Inflector.pluralize(@model_class).downcase.to_sym, options
               end
           else
             model_pages = []
             models = @model.find(:all, options)
           end

           self.instance_variable_set("@#{Inflector.underscore(@model_name)}_pages", model_pages)
           self.instance_variable_set("@#{Inflector.tableize(@model_name)}", models)
           @streamlined_items = models
           @streamlined_item_pages = model_pages
         end
         
         
          # if request.xhr?
          #   @con_name = controller_name
          #   render :update do |page|
          #     page << "if($('notice')) {Element.hide('notice');} if($('notice-error')) {Element.hide('notice-error');} if($('notice-empty')) {Element.hide('notice-empty');}"
          #     page.show 'notice-info'
          #     page.replace_html "notice-info", @controller.list_notice_info
          #     page.replace_html "#{@model_underscore}_list", :partial => render_path('list', :partial => true, :con_name => @con_name)
          #     filter_text = [ @model_name.pluralize ] + ( @page_options.filter.blank? ? [] : [ "Filter", @page_options.filter] )
          #     page.replace_html "breadcrumbs_text", neocast_breadcrumbs_text_innerhtml( :model => @model_name, :text => filter_text )
          #   end
          # else
          #     flash[:info] = @controller.list_notice_info if @controller.respond_to?( "list_notice_info" )
          # end
         render :partial => render_path('list') if request.xhr?
         render :template => generic_view('atom'), :controler => @model_name, :layout => false if params[:syndicated]
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
           render :partial => render_path('list') if request.xhr?
         end

       # Opens the search view.  The default is a criteria query view.
       def search
         self.instance = @model.new
         render(:partial => render_path('search'))
       end

       # Executes the search.  The default behavior is to create 
       # a criteria instance of the @model being searched and execute
       # the find_by_criteria method on the @model class.
       def find
         self.instance = @model.new(params[@model_symbol])
         @results = @model.find_by_criteria(instance)
         render(:partial => render_path('results'))
       end

       # Renders the Show view for a given instance.
       def show
         self.instance = @model.find(params[:id])
          if request.xhr? && params[:from_window]
            @id = instance.id
            @con_name = controller_name
            render :update do |page|
              page.replace_html "show_win_#{@id}_content", :partial => render_path('show', :partial => true, :con_name => @con_name)
            end
          else
            render(:partial => render_path('show'))
          end
       end

       # Opens the @model form for creating a new instance of the
       # given @model class.
       def new
         self.instance = @model.new
         if request.xhr? && params[:from_window]
             @id = instance.id
             @con_name = controller_name
             render :update do |page|
               page.replace_html "show_win_new_content", :partial => render_path('new', :partial => true, :con_name => @con_name)
             end
         else
           render(:partial => render_path('new'))
         end
       end

       # Uses the values from the rendered form to create a new
       # instance of the @model.  If the instance was successfully saved,
       # render the #show view.  If the save was unsuccessful, re-render
       # the #new view so that errors can be fixed.
       def create
         self.instance = @model.new(params[@model_symbol])
         if instance.save
           if request.xhr? && params[:from_window]
             @id = instance.id
             @con_name = controller_name
             render :update do |page|
               page.replace_html "show_win_new_content", :partial => render_path('show', :partial => true, :con_name => @con_name)
             end
           else
             flash[:notice] = "#{@model_name} was successfully created."
             redirect_to :action => 'show', :id => instance, :layout => 'streamlined_window'
           end   
         else
           @id = instance.id
           @con_name = controller_name
           render :update do |page|
             page.replace_html "show_win_new_content", :partial => render_path('new', :partial => true, :con_name => @con_name)
           end
         end
       end

       # Opens the @model form for editing an existing instance.
       def edit
         self.instance = @model.find(params[:id])
          if request.xhr? && params[:from_window]
              @id = instance.id
              @con_name = controller_name
              render :update do |page|
                page.replace_html "show_win_#{@id}_content", :partial => render_path('edit', :partial => true, :con_name => @con_name)
              end
          else
            render(:partial => render_path('edit'))
          end
       end

       # Uses the values from the rendered form to update an existing
       # instance of the @model.  If the instance was successfully saved,
       # render the #show view.  If the save was unsuccessful, re-render
       # the #edit view so that errors can be fixed.
       def update
         self.instance = @model.find(params[:id])
          if instance.update_attributes(params[@model_symbol])
            get_instance.tag_with(params[:tags].join(' ')) if params[:tags] && Object.const_defined?(:Tag)
            if request.xhr? && params[:from_window]
              @id = instance.id
              @con_name = controller_name
              render :update do |page|
                page.replace_html "show_win_#{@id}_content", :partial => render_path('show', :partial => true, :con_name => @con_name)
              end         
            else
              flash[:notice] = "#{@model_name} was successfully updated."
              redirect_to :action => 'show', :id => instance, :layout => 'streamlined_window'
            end
          else
            @id = instance.id
            @con_name = controller_name
            render :update do |page|
              page.replace_html "show_win_#{@id}_content", :partial => render_path('edit', :partial => true, :con_name => @con_name)
            end
          end
       end

       # Deletes a given instance of the @model class and re-renders the #list view.
       def destroy
         @model.find(params[:id]).destroy
         redirect_to :action => 'list'
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
       
       # Overrides the default ActionPack version of #render.  First, attempts
       # to render the request the standard way.  If the render fails, then 
       # attempts to render the Streamlined generic view of the same request.  
       # The method must first check if the request is for one of the @managed_views
       # or @managed_partials established at initialization time.  If so, it is 
       # rendered from the /app/views/streamlined/generic_views folder.  If not, the
       # exception that was originally thrown is propogated to the outer scope.
       def render(options = nil, deprecated_status = nil, &block) #:doc:
        puts "OPTIONS: #{options.inspect}"
        begin
          super(options, deprecated_status, &block)
        rescue ActionView::TemplateError => ex 
          raise ex
        rescue Exception => ex
          puts "EXCEPTION: #{ex}"
          if options
            if options[:partial] && @managed_partials.include?(options[:partial])
              options[:partial] = generic_view(options[:partial])
              super(options, deprecated_status, &block)
            elsif options[:action] && @managed_views.include?(options[:action])
              super(:template => generic_view(options[:action]))
            else
              raise ex
            end
          else
            view_name = default_template_name.split("/")[-1]
            super(:template => generic_view(view_name))
          end
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
            @model_name ||= self.class.model_name || Inflector.singularize(self.class.name.chomp("Controller"))
          end
          @model = Class.class_eval(@model_name)
          @model_symbol = Inflector.underscore(@model_name).to_sym
          if Object.const_defined? (@model_name + "UI")
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

        def order_options
          if @page_options.order?
            vals = @page_options.order.split(',')
            if @model.column_names.include? vals[0]
              @page_options.active_record_order_option
            else
              {:non_ar_column => vals[0].downcase.tr(" ", "_"), :dir => vals[1]}
            end
          else
            # override to set a default column sort, e.g. :order=>"col ASC|DESC"
            {}
          end
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

        def render_path(template, options = {:partial => true, :con_name => nil})
           options[:con_name] ||= controller_name
           template_file = "_#{template}" if options[:partial]
           File.exist?(File.join(RAILS_ROOT, 'app', 'views', options[:con_name], template_file + ".rhtml")) ? template : generic_view(template)
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
  
  module ClassMethods
    @custom_model_name = nil
    
    def acts_as_streamlined(options = {})
      class_eval <<-EOV
        include StreamlinedController::InstanceMethods
        
        if defined? AuthenticatedSystem
          include AuthenticatedSystem
          before_filter :login_required  
        end
        before_filter :initialize_page_options

        require_dependencies :ui, Dir["#{RAILS_ROOT}/app/streamlined/*.rb"].collect {|f| f.gsub(".rb", "")}
        depend_on :ui, Dir["#{RAILS_ROOT}/app/streamlined/*.rb"].collect {|f| f.gsub(".rb", "")}


        # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
        verify :method => :post, :only => [ :destroy, :create, :update ],
               :redirect_to => { :action => :list }
               
               def initialize_with_streamlined_variables
                  if self.class == StreamlinedController
                      RAILS_DEFAULT_LOGGER.warn("Cannot directly browse the Streamlined framework (/streamlined)")
                      raise "Cannot directly browse the Streamlined framework (/streamlined)" 
                  end

                  begin
                    initialize_streamlined_values
                    @managed_views = ['list']
                    @managed_partials = ['list', 'edit', 'show', 'new', 'form', 'popup', 'tags', 'tag_list', 'columns', 'show_columns', 'hide_columns']                    
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
        
    def generic_view(template)
      "../../vendor/plugins/streamlined/templates/generic_views/#{template}"
    end
    
    def syndication(options = {})
       @syndication_type = options[:type].nil? ? "rss" : options[:type].to_s
       @syndication_actions = options[:actions].nil? ? "list" : (options[:actions].map &:to_s)
    end
    
    def streamlined_model(mod)
      mod.instance_of?(String) ? @custom_model_name = mod : @custom_model_name = mod.name
    end
  end
  
end
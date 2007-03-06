module Streamlined::Controller::CrudMethods
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
    render :partial => 'list' if request.xhr?
    render :template => generic_view('atom'), :controler => @model_name, :layout => false if params[:syndicated]
  end
   # Renders the Show view for a given instance.
   def show
     self.instance = @model.find(params[:id])
     render_or_redirect('show')
   end

   # Opens the @model form for creating a new instance of the
   # given @model class.
   def new
     self.instance = @model.new
     render_or_redirect('new')
   end

   # Uses the values from the rendered form to create a new
   # instance of the @model.  If the instance was successfully saved,
   # render the #show view.  If the save was unsuccessful, re-render
   # the #new view so that errors can be fixed.
   def create
     self.instance = @model.new(params[@model_symbol])
     if instance.save
       flash[:notice] = "#{@model_name} was successfully created."
       render_or_redirect("show", :action=>"list")
     else
       render_or_redirect('new')
     end
   end

  # Opens the @model form for editing an existing instance.
  def edit
    self.instance = @model.find(params[:id])
    render_or_redirect('edit')
  end

  # Uses the values from the rendered form to update an existing
  # instance of the @model.  If the instance was successfully saved,
  # render the #show view.  If the save was unsuccessful, re-render
  # the #edit view so that errors can be fixed.
  def update
    self.instance = @model.find(params[:id])
    if instance.update_attributes(params[@model_symbol])
      get_instance.tag_with(params[:tags].join(' ')) if params[:tags] && Object.const_defined?(:Tag)
      flash[:notice] = "#{@model_name} was successfully updated."
      render_or_redirect("show", :action=>"list")
    else
      render_or_redirect("edit")
    end
  end

  def destroy
    @model.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
end   

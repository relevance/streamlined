module Streamlined::Controller::CrudMethods
  # Creates the list of items of the @managed model class. Default behavior
  # creates an Ajax-enabled table view that paginates in groups of 10.  The 
  # resulting view will use Prototype and XHR to allow the user to page
  # through the model instances.  
  #
  # If the request came via XHR, the action will render just the list partial,
  # not the entire list view.
  def list
    self.crud_context = :list
    options = pagination ? {:per_page => 10} : {}
    options.merge! order_options
    if filter?
      options.merge! :conditions=>model.conditions_by_like(filter) 
      @streamlined_items_count = model.count(:conditions => model.conditions_by_like(filter))
    else
      @streamlined_items_count = model.count
    end
    if pagination
       if options[:non_ar_column]
          col = options[:non_ar_column]
          dir = options[:dir]
          options.delete :non_ar_column
          options.delete :dir
          model_pages, models = paginate Inflector.pluralize(model).downcase.to_sym, options
          sort_models(models, col)
          models.reverse! if dir == 'DESC'
        else
          model_pages, models = paginate Inflector.pluralize(model).downcase.to_sym, options
        end
    else
      model_pages = []
      models = model.find(:all, options)
    end

    self.instance_variable_set("@#{Inflector.underscore(model_name)}_pages", model_pages)
    self.instance_variable_set("@#{Inflector.tableize(model_name)}", models)
    @streamlined_items = models
    @streamlined_item_pages = model_pages
    respond_to do |format|
      format.html {render :action=> "list"}
      format.js {render :partial => "list"}
      format.csv {render :text=> @streamlined_items.to_csv(model.columns.map(&:name))}
      format.xml  {render :xml => @streamlined_items.to_xml }
    end
  end

   # Renders the Show view for a given instance.
   def show
     self.crud_context = :show
     self.instance = model.find(params[:id])
     render_or_redirect(:success, 'show')
   end

   # Opens the model form for creating a new instance of the
   # given model class.
   def new
     self.crud_context = :new
     self.instance = model.new
     render_or_redirect(:success, 'new')
   end

   # Uses the values from the rendered form to create a new
   # instance of the model.  If the instance was successfully saved,
   # render the #show view.  If the save was unsuccessful, re-render
   # the #new view so that errors can be fixed.
   def create
     self.instance = model.new(params[model_symbol])
     if instance.save
       flash[:notice] = "#{model_name} was successfully created."
       self.crud_context = :show
       render_or_redirect(:success, "show", :action=>"list")
     else
       self.crud_context = :new
       render_or_redirect(:failure, 'new')
     end
   end

  # Opens the model form for editing an existing instance.
  def edit
    self.crud_context = :edit
    self.instance = model.find(params[:id])
    render_or_redirect(:success, 'edit')
  end

  # Uses the values from the rendered form to update an existing
  # instance of the model.  If the instance was successfully saved,
  # render the #show view.  If the save was unsuccessful, re-render
  # the #edit view so that errors can be fixed.
  def update
    self.instance = model.find(params[:id])
    if instance.update_attributes(params[model_symbol])
      # TODO: reimplement tag support
      # get_instance.tag_with(params[:tags].join(' ')) if params[:tags] && Object.const_defined?(:Tag)
      flash[:notice] = "#{model_name} was successfully updated."
      self.crud_context = :show
      render_or_redirect(:success, "show", :action=>"list")
    else
      self.crud_context = :edit
      render_or_redirect(:failure, "edit")
    end
  end

  def destroy
    self.instance = model.find(params[:id]).destroy
    render_or_redirect(:success, nil, :action => "list")
  end

  private
  delegates :pagination, :to=>:model_ui, :visibility=>:private
  attr_accessor :crud_context
  attr_accessor :default_order_options
  # TODO: Dump non_ar_column. 
  # Figure out whether a column is ar or not when using it!
  def order_options
    if order?
      column,order = sort_column, sort_order
      if model.column_names.include? column
        active_record_order_option
      else
        {:non_ar_column => column.downcase.tr(" ", "_"), :dir => order}
      end
    else
      default_order_options || {}
    end
  end
  
  def sort_models(models, column)
    models.sort! {|a,b| a.send(column.to_sym).to_s <=> b.send(column.to_sym).to_s}
  end

  
end   

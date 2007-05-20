module Streamlined::Controller::RelationshipMethods
  
 # Shows the relationship's configured +Edit+ view, as defined in streamlined_ui 
 # and Streamlined::Column.
 def edit_relationship
   self.instance = @root = model.find(params[:id])
   @rel_name = params[:relationship]
   relationship = relationship_for_name(@rel_name)
   set_items_and_all_items(relationship)
   render(:partial => relationship.edit_view.partial, :locals => {:relationship => relationship})
 end

 # Show's the relationship's configured +Show+ view, 
 # as defined in streamlined_ui and Streamlined::Column.
 def show_relationship
   self.instance = @root = model.find(params[:id])
   relationship = relationship_for_name(params[:relationship])
   render(:partial => relationship.show_view.partial, :locals => {:item => instance,
     :relationship => relationship, :streamlined_def => relationship.show_view})
 end

 # Add new items to the given relationship collection. Used by the #membership view, as 
 # defined in Streamlined::Column.
 def update_relationship
    self.instance = model.find(params[:id])
    rel_name = params[:rel_name].to_sym
    klass = Class.class_eval(params[:klass])
    relationship = relationship_for_name(rel_name)
    
    items = extract_ids_of_checked_items_from_hash(params[:item])
    instance.send(rel_name).clear
    instance.send(rel_name).push(klass.find(items))
    instance.save
    
    if relationship.edit_view.respond_to?(:render_on_update)
      @rel_name = rel_name
      @root = instance
      @current_id = instance.id
      set_items_and_all_items(relationship, params[:filter])
      # render :update do |page|
      render_or_redirect(:success, relationship.edit_view.render_on_update(rel_name, params[:id]))
      # end
    else
      render(:nothing => true)
    end
    
 end

 # Add new items to the given relationship collection. Used by the #membership view, as 
 # defined in Streamlined::Column.
 def update_n_to_one
  item = params[:item]
  self.instance = model.find(params[:id])
  rel_name = "#{params[:rel_name]}=".to_sym
  if item == 'nil' || item == nil
    instance.send(rel_name, nil)
  else
    if item.include?('::')
      item_id, item_name = item.split('::')
      new_item = Class.class_eval(item_name).find(item_id)
    else
      new_item = Class.class_eval(params[:klass]).find(item)
    end
    instance.send(rel_name, new_item)
  end
  instance.save
  render(:nothing => true)
 end
 
 private
 def set_items_and_all_items(relationship, item_filter = nil)
    @items = instance.send(@rel_name)
    if relationship.associables.size == 1
      @klass = Class.class_eval(params[:klass])
      @klass_ui = Streamlined::UI.get_ui(params[:klass])
      if item_filter
        @all_items = @klass.find(:all, :conditions => @klass.conditions_by_like(item_filter))
      else            
        @all_items = @klass.find(:all)
      end
    else
      @all_items = {}
      relationship.associables.each do |klass|
        if item_filter
          @all_items[klass.name] = klass.find(:all, :conditions => klass.conditions_by_like(item_filter))
        else
          @all_items[klass.name] = klass.find(:all)
        end
      end
    end
 end
 
 def relationship_for_name(rel_name)
   model_ui.relationships[rel_name.to_sym]
 end
 
 def extract_ids_of_checked_items_from_hash(items)
   items ? items.collect{|k,v| k if v=='on'}.reject{|i| i==nil} : []
 end
 
end
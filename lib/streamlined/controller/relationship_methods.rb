module Streamlined::Controller::RelationshipMethods
 # Shows the relationship's configured +Edit+ view, as defined in streamlined_ui 
 # and Streamlined::Column.
 def edit_relationship
   self.instance = @root = model.find(params[:id])
   @relationship_name = params[:relationship]
   rel_type = relationship_for_name(params[:relationship])
   set_items_and_all_items(relationship_for_name(@relationship_name))
   render(:partial => rel_type.edit_view.partial)
 end

 # Show's the relationship's configured +Show+ view, 
 # as defined in streamlined_ui and Streamlined::Column.
 def show_relationship
   self.instance = @root = model.find(params[:id])
   rel_type = relationship_for_name(params[:relationship])
   relationship = instance.class.reflect_on_association(params[:relationship].to_sym)
   render(:partial => rel_type.show_view.partial, :locals => {:item => instance, :relationship => relationship, :streamlined_def => rel_type.show_view})
 end

 # Add new items to the given relationship collection. Used by the #membership view, as 
 # defined in Streamlined::Column.
 def update_relationship
    self.instance = model.find(params[:id])
    rel_name = params[:rel_name].to_sym
    klass = Class.class_eval(params[:klass])
    relationship = model_ui.relationships[rel_name]
    
    items = params[:item].collect{|k,v| k if v=='on'}.reject{|i| i==nil}  
    instance.send(rel_name).clear
    instance.send(rel_name).push(klass.find(items))
    instance.save
    
    
    if relationship.edit_view.respond_to?(:render_on_update)
      @relationship_name = rel_name
      @root = instance
      set_items_and_all_items(relationship, params[:filter])
      render :update do |page|
        relationship.edit_view.render_on_update(page, rel_name, params[:id])
      end
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
      new_item = Class.class_eval(params[:klass]).find(item)
    else
      item_id, item_name = item.split('::')
      new_item = Class.class_eval(item_name).find(item_id)
    end
    instance.send(rel_name, new_item)
  end
  instance.save
  render(:nothing)
 end
 
 def relationship_for_name(rel_name)
   model_ui.relationships[rel_name.to_sym]
 end

 def set_items_and_all_items(rel_type, item_filter = nil)
    @items = instance.send(@relationship_name)
    if rel_type.associables.size == 1
      @klass = Class.class_eval(params[:klass])
      @klass_ui = Streamlined::UI.get_ui(params[:klass])
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
 
end
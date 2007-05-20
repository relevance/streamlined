module Streamlined::Controller::QuickAddMethods
  
  # TODO: needs refactoring
  def quick_add
    self.crud_context = :new
    set_instance_vars
    @model.class.delegate_targets.each do |dt| 
      assoc = @model.class.reflect_on_association(dt)
      target_class = assoc.class_name.constantize
      
      instance_variable_set("@#{target_class.name.underscore}", target_class.new)
    end
    self.instance = @model
    render_or_redirect(:success, 'quick_add')
  end
  
  # TODO: needs refactoring
  def save_quick_add
    set_instance_vars
    @success = true
    @model.class.delegate_targets.each do |dt| 
      assoc = @model.class.reflect_on_association(dt)
      target_class = assoc.class_name.constantize
      
      assoc_name = assoc.class_name.underscore.to_sym
      assoc_model = target_class.new(params[assoc_name])
      @success = assoc_model.save && @success
      instance_variable_set("@#{assoc_name}", assoc_model)
      @model.send("#{assoc_name}=", assoc_model)
    end
    @success = @model.save && @success
    self.instance = @model
    render_or_redirect(:success, 'save_quick_add')
  end
  
  private
  def set_instance_vars
    @model_class_name = params[:model_class_name]
    @model_name = @model_class_name.underscore
    @model = @model_class_name.constantize.new(params[@model_name.to_sym])
    @ui = Streamlined::UI.get_ui(@model.class)
    instance_variable_set("@#{@model_name}", @model)
  end
 
end
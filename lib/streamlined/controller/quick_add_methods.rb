module Streamlined::Controller::QuickAddMethods
  
  # TODO: needs refactoring
  def quick_add
    self.crud_context = :new
    @quick_add_model_class_name = params[:quick_add_model_class_name]
    @quick_add_model_name = @quick_add_model_class_name.underscore
    @quick_add_model = @quick_add_model_class_name.constantize.new
    @ui = Streamlined::UI.get_ui(@quick_add_model.class)
    instance_variable_set("@#{@quick_add_model_name}", @quick_add_model)
    @quick_add_model.class.delegate_targets.each do |dt| 
      assoc = @quick_add_model.class.reflect_on_association(dt)
      target_class = assoc.class_name.constantize
      instance_variable_set("@#{target_class.name.underscore}", target_class.new)
    end
    self.instance = @quick_add_model
    render_or_redirect(:success, 'quick_add')
  end
  
  # TODO: needs refactoring
  def save_quick_add
    @quick_add_model_class_name = params[:quick_add_model_class_name]
    @quick_add_model_name = @quick_add_model_class_name.underscore
    @quick_add_model = @quick_add_model_class_name.constantize.new(params[@quick_add_model_name.to_sym])
    @ui = Streamlined::UI.get_ui(@quick_add_model.class)
    instance_variable_set("@#{@quick_add_model_name}", @quick_add_model)
    @success = true
    @quick_add_model.class.delegate_targets.each do |dt| 
      assoc = @quick_add_model.class.reflect_on_association(dt)
      target_class = assoc.class_name.constantize
      assoc_name = assoc.class_name.underscore.to_sym
      assoc_model = target_class.new(params[assoc_name])
      @success = assoc_model.save && @success
      instance_variable_set("@#{assoc_name}", assoc_model)
      @quick_add_model.send("#{assoc_name}=", assoc_model)
    end
    @success = @quick_add_model.save && @success
    self.instance = @quick_add_model
    render_or_redirect(:success, 'save_quick_add')
  end
 
end
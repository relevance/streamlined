# per controller context, kept for the lifetime of the controller class
# and made available via delegation to controllers and views
class Streamlined::Context::ControllerContext
  attr_accessor :model_name, :render_filters, :db_action_filters
  
  DELEGATES = [:model_name, 
               :render_filters,
               :db_action_filters,
               :model, 
               :model_symbol, 
               :model_table, 
               :model_underscore, 
               :model_ui, 
               {:to=>:streamlined_controller_context}].freeze
  
  def model
    @model ||= Class.class_eval(model_name)
  end
  
  def model_symbol
    @model_symbol ||= Inflector.underscore(model_name).to_sym
  end
  
  def model_table
    @model_table ||= Inflector.tableize(model_name)
  end
  
  def model_underscore
    @model_underscore ||= Inflector.underscore(model_name)
  end
    
  def model_ui
    Streamlined.ui_for(model_name)
  end
end
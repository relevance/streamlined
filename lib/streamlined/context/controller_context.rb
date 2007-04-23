# per controller context, kept for the lifetime of the controller class
# and made available via delegation to controllers and views
class Streamlined::Context::ControllerContext
  attr_accessor :model_name, :render_filters
  
  DELEGATES = [:model_name, 
               :render_filters,
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
    model_ui ||= if Object.const_defined?(model_name + "UI")
      Class.class_eval(model_name + "UI")
    else
      temp = Class.new(Streamlined::UI.generic_ui)
      temp.model = model
      temp
    end
  end
end
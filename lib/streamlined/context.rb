class Streamlined::Context
  attr_accessor :model_name
  
  def model
    @model ||= Class.class_eval(model_name)
  end
end
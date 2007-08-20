module Streamlined::Controller::DbActionMethods
  include Streamlined::RenderMethods
  
  private
  def current_db_action_filter
    db_action_filters[current_action]
  end
  
  def execute_db_action_filter
    filter = current_db_action_filter
    if filter.is_a?(Proc)
      self.instance_eval(&filter)
    elsif filter.is_a?(Symbol)
      self.send(filter)
    else
      raise ArgumentError, "Invalid options for db_action_filter"
    end
  end
  
  def execute_db_action_with_default(&default_action)
    current_db_action_filter ? execute_db_action_filter : yield
  end
end
  

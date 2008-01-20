module Streamlined::Controller::DbActionMethods
  include Streamlined::RenderMethods
  
  private

  def current_before_streamlined_create_or_update_filter
    self.class.before_streamlined_create_or_update_filters[current_action]
  end
  
  def execute_before_streamlined_create_or_update_filter
    filter = current_before_streamlined_create_or_update_filter
    if filter.is_a?(Proc)
      self.instance_eval(&filter)
    elsif filter.is_a?(Symbol)
      self.send(filter)
    else
      raise ArgumentError, "Invalid options for db_action_filter - must pass either a Proc or a Symbol, you gave [#{filter.inspect}]"
    end
  end
  
  def execute_before_filter_and_yield(&default_action)
    execute_before_streamlined_create_or_update_filter if current_before_streamlined_create_or_update_filter
    yield
  end
end
  

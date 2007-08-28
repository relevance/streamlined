module Streamlined::Controller::OptionsMethods
  private
  def count_or_find_options
    result = self.class.count_or_find_options
    result.each_pair { |k, v| result[k] = self.send(v) if v.is_a?(Symbol) }
    result
  end
end
  

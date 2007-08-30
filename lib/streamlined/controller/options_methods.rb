module Streamlined::Controller::OptionsMethods
  private
  def merge_count_or_find_options(target)
    options = count_or_find_options
    if options.delete(:merge) && !target[:conditions].blank?
      target[:conditions] = "(#{target[:conditions]}) AND #{options[:conditions]}"
    else
      target.merge!(options)
    end
  end
  
  def count_or_find_options
    result = self.class.count_or_find_options
    result.each_pair { |k, v| result[k] = self.send(v) if v.is_a?(Symbol) }
    result
  end
end

module Streamlined::Helpers::FormHelper
  # If the validation_reflection plugin is available and working properly, check to see if the given 
  # relationship allows for a nil assignment.  If so, return the "Unassigned" option.  Otherwise, return nothing.
  def unassigned_if_allowed(klass, relationship, items)
    return "<option value='nil' #{'selected' unless items}>Unassigned</option>" unless klass.respond_to?("reflect_on_validations_for")
    require 'facet/module/alias_method_chain' unless Module.respond_to?('alias_method_chain')
    return "<option value='nil' #{'selected' unless items}>Unassigned</option>" unless Module.respond_to?('alias_method_chain')
    
    if klass.reflect_on_validations_for(relationship).collect {|v| v.macro}.include?(:validates_associated)
      return ""
    else
      return "<option value='nil' #{'selected' unless items}>Unassigned</option>"
    end
  end
end
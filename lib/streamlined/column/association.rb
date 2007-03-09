# Wrapper around ActiveRecord::Association.  Keeps track of the underlying association, the View definition and the Summary definition.
class Streamlined::Column::Association
  attr_reader :underlying_association
  attr_reader :view_def
  attr_reader :summary_def
  
  def initialize(assoc, view, summary)
    @underlying_association = assoc
    @view_def = view
    @summary_def = summary
  end

  # Returns a list of all the classes that can be used to satisfy this relationship.  In a polymorphic relationship, it is the union 
  # of every type that is configured :as the relationship type.  For direct associations, it is the listed type of the relationship.      
  def associables        
    return [Class.class_eval(@underlying_association.class_name)] unless @underlying_association.options[:polymorphic]
    results = []
    ObjectSpace.each_object(Class) do |klass|
      results << klass if klass.ancestors.include?(ActiveRecord::Base) && klass.reflect_on_all_associations.collect {|a| a.options[:as]}.include?(@underlying_association.name)
    end
    return results
  end
end


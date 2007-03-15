require 'relevance/delegates'

# Currently available Views:
# * :membership => simple scrollable list of checkboxes.  DEFAULT for n_to_many
# * :inset_table => full table view inserted into current table
# * :window => same table from :inset_table but displayed in a window
# * :filter_select => like :membership, but with an auto-filter text box and two checkbox lists, one for selected and one for unselected items
# * :polymorphic_membership => like :membership, but for polymorphic associations.  DEPRECATED: :membership will be made to handle this case.
# * :select => drop down box.  DEFAULT FOR n_to_one
#
# Currently available Summaries:
# * :count => number of associated items. DEFAULT FOR n_to_many
# * :name => name of the associated item. DEFAULT FOR n_to_one
# * :list => list of data from specified :fields
# * :sum => sum of values from a specific column of the associated items

# Wrapper around ActiveRecord::Association.  Keeps track of the underlying association, the View definition and the Summary definition.
class Streamlined::Column::Association < Streamlined::Column::Base
  attr_reader :underlying_association
  attr_reader :view_def
  attr_reader :summary_def
  attr_accessor :human_name
  
  delegates :name, :class_name, :to=>:underlying_association
  
  def initialize(assoc, view, summary)
    @underlying_association = assoc
    @view_def = view
    @summary_def = summary
    @human_name = name.to_s.humanize
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
  
  def render_td(view, item, model_ui, controller)
    div = <<-END
  <div id="#{relationship_div_id(item)}">
		#{view.render(:partial => summary_def.partial, 
                   :locals => {:item => item, :relationship => self, 
                   :streamlined_def => summary_def})}
  </div>
END
    div += <<-END unless read_only
  #{view.link_to_function("Edit", 
  "Streamlined.Relationships.open_relationship('#{relationship_div_id(item)}', 
                                                this, '/#{controller}')")}
END
    div
  end
  
  # TODO: eliminate the helper version of this
  def relationship_div_id(item, in_window = false)
    fragment = view_def ? view_def.id_fragment : "temp"
    "#{fragment}::#{name}::#{item.id}::#{class_name}#{'::win' if in_window}"
  end
  
end


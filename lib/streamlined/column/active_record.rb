require 'streamlined/view'
require 'streamlined/helper'

class Streamlined::Column::ActiveRecord < Streamlined::Column::Base
  include Streamlined::Helpers::FormHelper
  
  attr_accessor :ar_column, :human_name, :enumeration
  delegates :name, :to => :ar_column
  
  def initialize(ar_column)
    @ar_column = ar_column
    @human_name = ar_column.human_name if ar_column.respond_to?(:human_name)
  end

  def ==(o)
    return true if o.object_id == object_id
    return false unless self.class == o.class
    return self.ar_column == o.ar_column &&
           self.human_name == o.human_name &&
           self.enumeration == o.enumeration
  end
  
  def edit_view
    Streamlined::View::EditViews.create_relationship(:enumerable_select)
  end
  
  def show_view
    Streamlined::View::ShowViews.create_summary(:enumerable)
  end
  
  def render_input(view)
    if enumeration
      # TODO: this is pretty hacky; a new method should probably be created to return true/false
      # based on whether or not a given column can receive an 'unassigned' value
      choices = enumeration.collect { |e| [e, e] }
      choices.unshift(['Unassigned', nil]) if unassigned_if_allowed(@model, name.to_sym, @items)
      view.select(view.model_underscore, name, choices)
    else
      view.input(view.model_underscore, name)
    end
  end
  
  def render_td(view, item)
    if enumeration
      div = <<-END
    <div id="#{relationship_div_id(name, item)}">
  		#{view.render(:partial => show_view.partial, 
                    :locals => {:item => item, :relationship => self, 
                    :streamlined_def => show_view})}
    </div>
END
      div += <<-END unless read_only
    #{view.link_to_function("Edit", 
    "Streamlined.Enumerations.open_enumeration('#{relationship_div_id(name, item)}', 
                                                  this, '/#{view.controller_name}')")}
END
      div
    else
      super
    end
  end
end
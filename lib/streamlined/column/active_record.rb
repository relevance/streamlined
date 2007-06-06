class Streamlined::Column::ActiveRecord < Streamlined::Column::Base
  attr_accessor :ar_column, :human_name, :enumeration, :check_box
  delegates :name, :to => :ar_column
  
  def initialize(ar_column, parent_model)
    @ar_column = ar_column
    @human_name = ar_column.human_name if ar_column.respond_to?(:human_name)
    @parent_model = parent_model
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
  
  def render_td_show(view, item)
    if enumeration
      id = relationship_div_id(name, item)
      div = div_wrapper(id) do
  		  view.render(:partial => show_view.partial, 
                    :locals => {:item => item, :relationship => self, 
                    :streamlined_def => show_view})
      end
    else
      render_content(view, item)
    end
  end
  
  def render_td_list(view, item)
    id = relationship_div_id(name, item)
    div = render_td_show(view, item)
    div += view.link_to_function("Edit", "Streamlined.Enumerations." <<
      "open_enumeration('#{id}', this, '/#{view.controller_name}')") if enumeration && editable
    div
  end
  
  def render_td_edit(view, item)
    if enumeration
      result = render_enumeration_select(view, item)
    elsif check_box
      result = view.check_box(model_underscore, name)
    else
      result = view.input(model_underscore, name)
    end
    wrap(result)
  end
  alias :render_td_new :render_td_edit
  
  def render_enumeration_select(view, item)
    id = relationship_div_id(name, item)
    choices = enumeration.to_2d_array
    choices.unshift(unassigned_option) if column_can_be_unassigned?(parent_model, name.to_sym)
    view.select(model_underscore, name, choices)
  end
end
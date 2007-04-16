class Streamlined::Column::ActiveRecord < Streamlined::Column::Base
  attr_accessor :ar_column, :human_name
  delegates :name, :to=>:ar_column
  def initialize(ar_column)
    @ar_column = ar_column
    @human_name = ar_column.human_name if ar_column.respond_to?(:human_name)
  end

  def ==(o)
    return true if o.object_id == object_id
    return false unless self.class == o.class
    return self.ar_column == o.ar_column &&
           self.human_name == o.human_name
  end
  
  def render_input(view)
    view.input(view.model_underscore, name)    
  end
end
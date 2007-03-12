class Streamlined::Column::ActiveRecord
  include Streamlined::Column
  attr_accessor :ar_column
  delegates :name, :human_name, :to=>:ar_column
  def initialize(ar_column)
    @ar_column = ar_column
  end

  def ==(o)
    return true if o.object_id == object_id
    return false unless self.class == o.class
    return self.ar_column == o.ar_column
  end

  def render_td(view, item, model_ui, controller)
    "<td>#{ERB::Util.h(item.send(self.name))}</td>"
  end

end

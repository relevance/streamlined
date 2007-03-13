class Streamlined::Column::Addition < Streamlined::Column::Base
  attr_accessor :name, :human_name

  def initialize(sym)
    @name = sym.to_s
    @human_name = sym.to_s.humanize
  end

  # Array#== calls this
  def ==(o)
    return true if o.object_id == object_id
    return false unless self.class === o
    return name.eql?(o.name)
  end
  
  def render_td(view, item, model_ui, controller)
    h(item.send(self.name))
  end
end

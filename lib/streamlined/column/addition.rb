class Streamlined::Column::Addition < Streamlined::Column::Base
  attr_accessor :name, :human_name

  def initialize(sym, parent_model)
    @name = sym.to_s
    @human_name = sym.to_s.humanize
    @read_only = true
    @parent_model = parent_model
  end

  # Array#== calls this
  def ==(o)
    return true if o.object_id == object_id
    return false unless self.class === o
    return name.eql?(o.name)
  end
  
  def render_td_show(view, item)
    render_content(view, item)
  end
end

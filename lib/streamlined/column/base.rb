class Streamlined::Column::Base
  include ERB::Util
  attr_accessor :read_only, :link_to
  def set_attributes(hash)
    hash.each do |k,v|
      sym = "#{k}="
      self.send sym, v
    end
  end
  def render_td(view, item, model_ui, controller)
    content = h(item.send(self.name))
    if link_to
      link_args = link_to.has_key?(:id) ? link_to : link_to.merge(:id=>item)
      view.wrap_with_link(link_args) {content}
    else
      content
    end
  end
end
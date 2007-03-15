class Streamlined::Column::Base
  include ERB::Util
  attr_accessor :read_only, :link_to, :popup
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
      content = view.wrap_with_link(link_args) {content}
    end
    if popup
      popup_args = popup.has_key?(:id) ? popup : popup.merge(:id=>item)
      content = "<span class=\"sl-popup\">#{view.invisible_link_to(popup_args)}#{content}</span>"
    end
    content
  end
  # TODO: make a streamlined_context that delegates to pageoptions, etc.
  def sort_image(context, view)
    if context.sort_column?(self)
      direction = context.ascending? ? 'up' : 'down'
      view.image_tag("streamlined/arrow-#{direction}_16.png", {:height => '10px', :border => 0})
    else
      ''
    end
  end
  def render_th(context,view)
    x = Builder::XmlMarkup.new
    x.th(:scope=>"col", :class=>"sortSelector") {
      x << human_name
      x << sort_image(context,view)
    }
  end
end
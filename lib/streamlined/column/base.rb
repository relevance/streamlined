require 'streamlined/view'
require 'streamlined/helper'

class Streamlined::Column::Base
  include Streamlined::Helpers::FormHelper
  include ERB::Util
  attr_accessor :link_to, :link_to_in_list, :popup, :parent_model, :wrapper
  attr_with_default :read_only, 'false'
  attr_with_default :create_only, 'false'
  attr_with_default :update_only, 'false'
  attr_with_default :allow_html, 'false'
  attr_with_default :edit_in_list, 'true'
  attr_with_default :unassigned_value, '"Unassigned"'
  
  def editable
    !(read_only || create_only) && edit_in_list
  end
  
  def model_underscore
    parent_model.name.underscore
  end
  
  def form_field_id
    "#{model_underscore}_#{name_as_id}"
  end
  
  def name_as_id
    "#{name}_id"
  end
  
  def belongs_to?
     false
  end
  
  def unassigned_option
    [unassigned_value, nil]
  end
  
  def validates_presence_of?
    col_name = belongs_to? ? name_as_id : name
    parent_model.reflect_on_validations_for(col_name).find {|e| e.macro == :validates_presence_of }
  end
  
  def set_attributes(hash)
    hash.each do |k,v|
      sym = "#{k}="
      self.send sym, v
    end
  end
  
  def render_td(view, item)
    if read_only
      render_td_show(view, item)
    else
      send "render_td_#{view.crud_context}", view, item
    end
  end
  
  [:show, :edit, :list, :new].each do |meth|
    define_method("render_td_#{meth}") do |*args|
      "[TBD: render_td_#{meth} for #{self.class}]"
    end
  end
  
  def render_content(view, item)
    content = item.send(self.name)
    content = h(content) unless allow_html
    if link_to
      link_args = link_to.has_key?(:id) ? link_to : link_to.merge(:id=>item)
      content = view.wrap_with_link(link_args) {content}
    end
    
    if link_to_in_list && view.crud_context == :list
      link_args = link_to_in_list.has_key?(:id) ? link_to_in_list : link_to_in_list.merge(:id=>item)
      content = view.wrap_with_link(link_args) {content}  
    end
    
    if popup
      popup_args = popup.has_key?(:id) ? popup : popup.merge(:id=>item)
      content = "<span class=\"sl-popup\">#{view.invisible_link_to(popup_args)}#{content}</span>"
    end
    content
  end
  
  # TODO: make a request_context that delegates to other bits
  def sort_image(context, view)
    if context.sort_column?(self)
      direction = context.sort_ascending? ? 'up' : 'down'
      view.image_tag("streamlined/arrow-#{direction}_16.png", {:height => '10px', :border => 0})
    else
      ''
    end
  end
  
  def render_th(context,view)
    x = Builder::XmlMarkup.new
    x.th(:class => "sortSelector", :scope => "col", :col => name) do
      x << human_name
      x << sort_image(context,view)
    end
  end
  
  def is_displayable_in_context?(view)
    # TODO: extract this nastiness into a class?  Only if we see one more need for objectified crud contexts!!!!!!
    case view.crud_context
    when :new
      !(self.read_only || self.update_only)
    when :show, :list
      true
    when :edit
      !(self.read_only || self.create_only)
    end
  end
  
  # TODO: eliminate the helper version of this
  def relationship_div_id(name, item, class_name = '', in_window = false)
    fragment = edit_view ? edit_view.id_fragment : "temp"
    "#{fragment}::#{name}::#{item.id}::#{class_name}#{'::win' if in_window}"
  end
  
  def div_wrapper(id, &block)
    "<div id=\"#{id}\">#{yield}</div>"
  end
  
  def wrap(content)
    wrapper && wrapper.respond_to?(:call) ? wrapper.call(content) : content
  end
end
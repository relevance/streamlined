# By default, headers are based on the class name (e.g. 'Edit Person')
# If your model class implements a name method, 
# you will get that instead (e.g. 'Edit John Doe')
module Streamlined::Helpers::HeaderHelper
  def render_show_header
    render_header
  end         
  
  def render_edit_header
    render_header("Edit")
  end

  def render_new_header
    render_header("New")
  end
  
  def render_header(prefix=nil)
    html = Builder::XmlMarkup.new
    html.div(:class => "streamlined_header") do
      html.h2(header_text(prefix))
    end
  end
  
  def header_text(prefix=nil)
    case prefix
      when "New"
        header_name = model_name.titleize
      else
        name_exists = !instance.nil? && instance.respond_to?(:name) && !instance.name.blank?
        header_name = name_exists ? instance.name : model_name.titleize
    end
    header = prefix ? "#{prefix} #{header_name}" : header_name
  end
  
  def prefix_for_crud_context
    case crud_context
      when :edit then "Edit"
      when :new then "New"
    end
  end
end

# By default, headers are based on the class name (e.g. 'Edit Person')
# If your model class implements a name method, 
# you will get that instead (e.g. 'Edit John Doe')
module Streamlined::Helpers::HeaderHelper
  def render_show_header
    render_header
  end         
  
  def render_edit_header
    render_header("Editing")
  end

  def render_new_header
    render_header("New")
  end
  
  def render_header(prefix=nil)
    header_name = instance.respond_to?(:name) ? instance.name : model_name.titleize
    header = prefix ? "#{prefix} #{header_name}" : header_name
    html = Builder::XmlMarkup.new
    html.div(:class => "streamlined_header") { html.h2(header) }
  end
end

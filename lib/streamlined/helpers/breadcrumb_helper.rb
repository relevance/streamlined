module Streamlined::Helpers::BreadcrumbHelper
  attr_with_default(:breadcrumb) {false}

  DELIMETER = "<"
  
  def render_breadcrumb
    html = Builder::XmlMarkup.new
    html.div(:id => "breadcrumb") do
      html << link_to("Home", "/")
      html << " #{DELIMETER} " 
      if crud_context != :list
        html << link_to(list_node_text, :action => "list")
        html << " #{DELIMETER} "
        html << header_text(prefix_for_crud_context)
      else
        html << list_node_text
      end
    end
    html.target!
  end
  
  private 
  def list_node_text
    model_name.titleize.pluralize
  end
end

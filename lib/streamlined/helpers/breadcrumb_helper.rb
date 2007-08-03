module Streamlined::Helpers::BreadcrumbHelper
  attr_with_default(:breadcrumb) {false}
  
  def render_breadcrumb
    html = Builder::XmlMarkup.new
    html.div(:id => "breadcrumb") do
      html << link_to(model_name.pluralize, :action => "list")
      unless crud_context == :list
        header = case crud_context
          when :edit then header_text("Edit")
          when :new then header_text("New")
          else header_text
        end
        html << " < #{header}"
      end
    end
    html.target!
  end
end

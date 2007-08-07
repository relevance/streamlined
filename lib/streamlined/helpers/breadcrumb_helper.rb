module Streamlined::Helpers::BreadcrumbHelper
  include Streamlined::Breadcrumb
  attr_with_default(:breadcrumb) {false}
  
  def render_breadcrumb
    html = Builder::XmlMarkup.new
    html.div(:id => "breadcrumb") do
      html << trail.join(" #{DELIMETER} ")
    end
    html.target!
  end
  
  private
  def default_trail
    trail = [Nodes::HOME]
    if crud_context == :list
      trail << Nodes::LIST_UNLINKED
    else
      trail << Nodes::LIST_LINKED << Nodes::CRUD_CONTEXT
    end
  end
  
  def trail
    parts = breadcrumb_trail.empty? ? default_trail : breadcrumb_trail
    parts.collect { |e| e.is_a?(Proc) ? self.instance_eval(&e) : e }
  end
end

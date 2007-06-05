module Streamlined::Helpers::RenderHelper
  
  def render_tabs(*tabs)
    html = Builder::XmlMarkup.new
    html.div(:class => "tabber") do
      tabs.each { |tab| render_tab(html, tab) }
    end
    html
  end

private
  
  def render_tab(html, tab)
    raise "tab missing partial to render" if tab[:partial].blank?
    title = tab[:name] || tab[:partial].tableize.humanize
    id = tab[:id] || tab[:partial]
    html.div(:class => "tabbertab", :title => title, :id => id) do
      html << render(:partial => tab[:partial])
    end
  end
  
end
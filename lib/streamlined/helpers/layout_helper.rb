# These helpers are needed by the layout
# You might need to include them in non-streamlined controllers that want to share layout
module Streamlined::Helpers::LayoutHelper
  # override these in your own application helper, or controller specific helpers
  def streamlined_side_menus
    [
      ["TBD", {:action=>"list"}]
    ]
  end
  def streamlined_top_menus
    [
      ["TBD", {:action=>"new"}]
    ]
  end
  # TODO: move to REST or eliminate
  def streamlined_auto_discovery_link_tag
    # return if @syndication_type.nil? || @syndication_actions.nil?
    # 
    # if @syndication_actions.include? params[:action]
    #   "<link rel=\"alternate\" type=\"application/#{@syndication_type.downcase}+xml\" title=\"#{@syndication_type.upcase}\" href=\"#{params[:action]}/xml\" />"
    # end
  end
  def streamlined_branding
    "Streamlined"
  end

  def streamlined_footer
    <<-END
Brought to you by Streamlined (<a href="http://www.streamlinedframework.org">StreamlinedFramework.org</a>  
END
  end
end
module Streamlined::View::RenderMethods
  include Streamlined::RenderMethods
  def render(options = {}, old_local_assigns = {}, &block)
    options = convert_all_options if controller.ancestors.include?(Streamlined::Controller)
    super(options, deprecated_status, &block)
  end
end
  

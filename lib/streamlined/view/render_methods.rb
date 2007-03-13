module Streamlined::View::RenderMethods
  include Streamlined::RenderMethods
  def controller_name
    controller.controller_name # needed by Streamlined::RenderMethods
  end
  def render(options = {}, old_local_assigns = {}, &block)
    options = convert_all_options(options)
    super(options, old_local_assigns, &block)
  end
end
  

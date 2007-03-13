module Streamlined::Controller::RenderMethods
  include Streamlined::RenderMethods
  private
  def render_or_redirect(action, redirect=nil)
    if request.xhr?
      @id = instance.id
      render :action => action, :layout=>false
    else
      if redirect
        redirect_to(redirect)
      else
        render :action => action
      end
    end
  end
  
  def render(options = {}, deprecated_status = nil, &block) 
    options = convert_all_options(options)
    super(options, deprecated_status, &block)
  end
end
  

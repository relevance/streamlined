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

  def convert_partial_options(options)
    partial = options[:partial]
    if partial && managed_partials_include?(partial)
      unless specific_template_exists?("#{controller_name}/_#{partial}")
        options.delete(:partial)
        options[:template] = generic_view("_#{partial}")
        options[:layout] = false unless options.has_key?(:layout)
      end
    end
    options
  end

  def render(options = {}, deprecated_status = nil, &block) 
    options = convert_all_options(options)
    super(options, deprecated_status, &block)
  end
end
  

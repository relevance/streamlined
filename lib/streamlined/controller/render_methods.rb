module Streamlined::Controller::RenderMethods
  include Streamlined::RenderMethods
  private
  def render_or_redirect(action, redirect=nil)
    @id = instance.id
    if redirect && !request.xhr?
      redirect_to(redirect)
    else
      respond_to do |format|
        format.html {render :action => action}
        format.js {render :action => action, :layout=>false}
        format.xml  { render :xml => instance.to_xml }
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
  

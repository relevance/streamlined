module Streamlined::Controller::RenderMethods
  include Streamlined::RenderMethods
  private
  def render_or_redirect(status, action, redirect=nil)
    @id = instance.id
    current_action = params[:action].intern

    if render_filters[current_action] && render_filters[current_action][status]
      execute_render_filter(render_filters[current_action][status])
    elsif redirect && !request.xhr?
      redirect_to(redirect)
    else
      respond_to do |format|
        format.html {render :action => action}
        format.js {render :action => action, :layout=>false}
        format.xml  { render :xml => instance.to_xml }
      end
    end
  end
  
  def execute_render_filter(options)
    if options.is_a?(Proc)
      options.call(self)
    else
      self.instance = instance.send(options[:with_instance]) if options[:with_instance]    
      if options[:render_tabs]
        render_tabs(*options[:render_tabs])
      elsif options[:render]
        render(options[:render])
      elsif options[:redirect_to]
        redirect_to(options[:redirect_to])
      elsif options[:render_append]
        render_append(*options[:render_append])
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
  

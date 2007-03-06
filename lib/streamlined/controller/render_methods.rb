module Streamlined::Controller::RenderMethods
  private
  
  def generic_view(template)
    "#{STREAMLINED_GENERIC_VIEW_ROOT}/#{template}"
  end

  def render_streamlined_ajax(action, redirect=nil)
    if request.xhr?
      @id = instance.id
      @con_name = controller_name
      render :template => render_path(action, :con_name => @con_name), :layout=>false
    else
      if redirect
        redirect_to(redirect)
      else
        render :template=>render_path(action)
      end
    end
  end

  # Overrides the default ActionPack version of #render.  First, attempts
  # to render the request the standard way.  If the render fails, then 
  # attempts to render the Streamlined generic view of the same request.  
  # The method must first check if the request is for one of the @managed_views
  # or @managed_partials established at initialization time.  If so, it is 
  # rendered from the /app/views/streamlined/generic_views folder.  If not, the
  # exception that was originally thrown is propogated to the outer scope.
  def render(options = {}, deprecated_status = nil, &block) #:doc:
    # normalize to a hash or stuff will break -sdh
    options = { :update => true } if options == :update
    begin
      super(options, deprecated_status, &block)
    rescue ActionView::TemplateError => ex 
      raise ex
    rescue Exception => ex
      if options.size > 0
        if options[:partial] && @managed_partials.include?(options[:partial])
          options[:partial] = generic_view(options[:partial])
          super(options, deprecated_status, &block)
        elsif options[:action] && @managed_views.include?(options[:action])
          options.merge!(:template => generic_view(options[:action]))
          options.delete(:action)
          super(options)
        else
          raise ex
        end
      else
        view_name = default_template_name.split("/")[-1]
        super(:template => generic_view(view_name))
      end
    end
  end

  def render_path(template, options = {})
    raise "Do not use :partial" if options.has_key?(:partial)
    # strip out the "_" in partials
    result_name = template.gsub(/(.*\/)_([^\/]+$)/,"\\1\\2")
    options[:con_name] ||= controller_name
     File.exist?(File.join(RAILS_ROOT, 'app', 'views', options[:con_name], template + ".rhtml")) ? result_name : generic_view(result_name)
  end


end
  

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
      self.instance_eval(&options)
    else
      self.instance = instance.send(options[:with_instance]) if options[:with_instance]    
      if options[:render_tabs]
        render_tabs(options[:render_tabs])
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

  def render_partials(*args)
    content = args.collect { |p| render_to_string(:template => partial_name(p), :layout => false) }
    render :text => content.join, :layout => true
  end
  
  # Note that when you pass in a partial and locals, if you are using shared, don't pass in ..
  # Ex: render_tabs :accountants, {:partial => 'shared/persona/display_personas', :locals => {:persona => accountant}}
  def render_tabs(*args)
    content = "<div class='tabber'>"
    args.each { |tab| content << render_a_tab(tab) }
    content << "</div>"
    render :text => content, :layout => true
  end
  
  def render_a_tab(tab)
    raise ArgumentError, ":name is required" unless tab[:name] != nil
    raise ArgumentError, ":partial is required" unless tab[:partial] != nil
    tab_name = tab[:name]
    param_next_to_tab_name = tab[:partial]
    

    result = ""
    locals = nil
    
    if param_next_to_tab_name.is_a?(Hash)
      raise ":partial required if tab content is a Hash" unless param_next_to_tab_name[:partial] != nil
      raise ":locals required if tab content is a Hash" unless param_next_to_tab_name[:locals] != nil
      file_name = param_next_to_tab_name[:partial]
      locals = param_next_to_tab_name[:locals]
    else
      file_name = partial_name(param_next_to_tab_name)
    end
 
    result << "<div class='tabbertab' title='#{tab_name.to_s.tableize.humanize}' id='#{tab_name}'>"
    
    if locals
      result << render_to_string(:partial => file_name, :locals => locals)
    else
      result << render_to_string(:template => file_name, :layout => false)
    end
    
    result << '</div>'
    result
  end
  
  def partial_name(file_name)
    index = file_name.to_s.rindex('/')
    if index.nil?
      file_name = "_#{file_name}"
    else
      file_name = file_name.dup.insert(index + 1, '_')
    end
    "#{params[:controller]}/#{file_name}"
  end
  
  # Render a full view along with an extra partial underneath it
  def render_append(*args)
    full_view = args[0]
    partial = args[1]
    content = ''
    content << render_to_string(:template => full_view, :layout => false)
    file_name = partial_name(partial)
    content << render_to_string(:template => file_name, :layout => false)        
    render :text => content, :layout => true
  end
end
  

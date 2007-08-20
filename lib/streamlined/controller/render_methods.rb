module Streamlined::Controller::RenderMethods
  include Streamlined::RenderMethods

  private
  def render_filter_exists?(name)
    render_filters[current_action] && render_filters[current_action][name]
  end
  
  def render_or_redirect(status, action, redirect=nil)
    @id = instance.id
    if render_filter_exists?(status)
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
    elsif options.is_a?(Symbol)
      self.send(options)
    else
      raise ArgumentError, "Invalid options for render_filter"
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
    content = args.collect { |p| 
      p = {:partial=>p} if String === p
      if p[:tabs]
        render_tabs_to_string(*p[:tabs])
      else
        render_to_string(p) 
      end
    }
    render :text => content.join, :layout => true
  end

  def render_tabs(*args)
    render :text => render_tabs_to_string(*args), :layout => true
  end
  
  # Note that when you pass in a partial and locals, if you are using shared, don't pass in ..
  # Ex: render_tabs :accountants, {:partial => 'shared/persona/display_personas', :locals => {:persona => accountant}}
  def render_tabs_to_string(*args)
    content = "<div class='tabber'>"
    args.each { |tab| content << render_a_tab_to_string(tab) }
    content << "</div>"
  end
  
  def render_a_tab_to_string(tab)
    tab_name = tab.delete(:name)
    raise ArgumentError, ":name is required" unless tab_name
    raise ArgumentError, "render args are required" if tab.empty?
    id = tab[:id] || tab_name.gsub(" ", "_").downcase
    result = ""
    result << "<div class='tabbertab' title='#{tab_name}' id='#{id}'>"
    result << render_to_string(tab)
    result << '</div>'
    result
  end
end
  

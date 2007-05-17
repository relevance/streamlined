# render overrides shared by controllers and views
module Streamlined::RenderMethods
  private
  def generic_view(template)
    generic_override = File.join(STREAMLINED_GENERIC_OVERRIDE_ROOT, template)
    File.exist?(File.join(RAILS_ROOT, 'app', 'streamlined', 'views', template + ".rhtml")) ? generic_override : "#{STREAMLINED_GENERIC_VIEW_ROOT}/#{template}"
  end

  def managed_views_include?(action)
    @managed_views.include?(action)
  end

  def managed_partials_include?(action)
    @managed_partials.include?(action)
  end

  # Returns true if the given template exists under <tt>app/views</tt>.
  # The template name can optionally include an extension.  If an extension
  # is not provided, <tt>rhtml</tt> will be used by default.
  def specific_template_exists?(template)
    template, extension = template.split('.')
    path = File.join(RAILS_ROOT, "app/views", template)
    File.exist?("#{path}.#{extension || 'rhtml'}")
  end
  
  def convert_default_options(options)
    options = { :update => true } if options == :update
    options = {:action=>action_name} if options.empty?
    options
  end
  
  def convert_action_options(options)
    action = options[:action]
    if action && managed_views_include?(options[:action])
      unless specific_template_exists?("#{controller_name}/#{options[:action]}")
        options.delete(:action)
        options[:template] = generic_view(action)
      end
    end
    options
  end
  
  def convert_all_options(options)
    options = convert_default_options(options)
    options = convert_action_options(options)
    options = convert_partial_options(options)
  end
  
end
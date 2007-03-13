# render overrides shared by controllers and views
module Streamlined::RenderMethods
  private
  def generic_view(template)
    "#{STREAMLINED_GENERIC_VIEW_ROOT}/#{template}"
  end

  def managed_views_include?(action)
    @managed_views.include?(action)
  end

  def managed_partials_include?(action)
    @managed_partials.include?(action)
  end

  #TODO: Expand to handle non-rhtml
  def specific_template_exists?(template)
    path = File.join(RAILS_ROOT, "app/views", template)
    File.exist?("#{path}.rhtml")
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
  
  def convert_partial_options(options)
    partial = options[:partial]
    if partial && managed_partials_include?(partial)
      unless specific_template_exists?("#{controller_name}/_#{partial}")
        options.delete(:partial)
        options[:file] = generic_view("_#{partial}")
        options[:layout] = false unless options.has_key?(:layout)
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
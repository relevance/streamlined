module Streamlined::View::RenderMethods
  include Streamlined::RenderMethods
  def controller_name
    controller.controller_name # needed by Streamlined::RenderMethods
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
  def render(options = {}, old_local_assigns = {}, &block)
    options = convert_all_options(options)
    super(options, old_local_assigns, &block)
  end
end
  

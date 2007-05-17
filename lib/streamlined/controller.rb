# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com

# This is not in init.rb because constants created there seem to get blown away! Yuck.
raise "Must have a RAILS_ROOT" unless RAILS_ROOT
# Using all? absolute paths to deal with Ruby/JRuby launch differences!
STREAMLINED_ROOT = Pathname.new(File.join(File.dirname(__FILE__), "../..")).expand_path.to_s
STREAMLINED_TEMPLATE_ROOT = 
File.join(Pathname.new(STREAMLINED_ROOT).relative_path_from(Pathname.new(RAILS_ROOT+"/app/views").expand_path),
          "/templates")
STREAMLINED_GENERIC_VIEW_ROOT = "#{STREAMLINED_TEMPLATE_ROOT}/generic_views"
STREAMLINED_GENERIC_OVERRIDE_ROOT = File.join('..', 'streamlined', 'views')

module Streamlined; end
module Streamlined::Controller; end

require 'streamlined/controller/crud_methods'
require 'streamlined/controller/enumeration_methods'
require 'streamlined/controller/relationship_methods'
require 'streamlined/controller/render_methods'
require 'streamlined/controller/quick_add_methods'

module Streamlined::Controller::InstanceMethods
  include Streamlined::Controller::CrudMethods
  include Streamlined::Controller::EnumerationMethods
  include Streamlined::Controller::RenderMethods
  include Streamlined::Controller::RelationshipMethods
  include Streamlined::Controller::QuickAddMethods
  
  def index
    list
  end
  
  # Creates the popup window for an item
  def popup
    self.instance = model.find(params[:id])
    render :partial => 'popup'
  end


  protected
  
  def instance
    self.instance_variable_get("@#{Inflector.underscore(model_name)}")
  end

  def instance=(value)
    self.instance_variable_set("@#{Inflector.underscore(model_name)}", value)
    @streamlined_item = value
  end
  
       
  private
  
  def initialize_request_context
    @streamlined_request_context = Streamlined::Context::RequestContext.new(params[:page_options])
  end
      
  def initialize_streamlined_values(mod_name = nil)
    @streamlined_controller_context = Streamlined::Context::ControllerContext.new
    @streamlined_controller_context.model_name = mod_name || self.class.model_name || Inflector.classify(self.class.controller_name)
    @streamlined_controller_context.render_filters = self.class.render_filters
    # TODO: why isn't this in the html head?
    @page_title = "Manage #{model_name.pluralize}"
  end

  # rewrite of rails method
  def paginator_and_collection_for(collection_id, options) #:nodoc:
    klass = model
    # page  = @params[options[:parameter]]
    page = streamlined_request_context.page
    count = count_collection_for_pagination(klass, options)
    paginator = ActionController::Pagination::Paginator.new(self, count, options[:per_page], page)
    collection = find_collection_for_pagination(klass, options, paginator)

    return paginator, collection 
  end


  def streamlined_logger
    RAILS_DEFAULT_LOGGER
  end
        
        
end

module Streamlined::Controller::ClassMethods  
  @custom_model_name = nil

  def acts_as_streamlined(options = {})
    @helper_overrides = options[:helpers] || []
    class_eval do
      attr_reader :streamlined_controller_context, :streamlined_request_context
      helper_method :crud_context
      # delegated helpers do not appear as routable actions!
      def self.delegate_non_routable(*delegates_args)
        delegates *delegates_args
        delegates_args.each {|arg| hide_action(arg)}
      end
      delegate_non_routable(*Streamlined::Context::ControllerContext::DELEGATES)
      delegate_non_routable(*Streamlined::Context::RequestContext::DELEGATES)
      include Streamlined::Controller::InstanceMethods
      # TODO: SDH hates this and would like to see apps have to turn auth in their own controllers
      if defined? AuthenticatedSystem
        include AuthenticatedSystem
        before_filter :login_required  
      end
      before_filter :initialize_request_context
      require_dependencies :ui, Dir["#{RAILS_ROOT}/app/streamlined/*.rb"].collect {|f| f.gsub(".rb", "")}
      # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
      verify :method => :post, :only => [ :destroy, :create, :update ],
            :redirect_to => { :action => :list }
      # stick streamlined's render overrides onto the view
      # This is fragile because it duplicates Rails code
      # Have to in order to inject methods at the right time!
      def self.view_class
        @view_class ||=
          # create a new class based on the default template class and include helper methods
          returning Class.new(ActionView::Base) do |view_class|
            # inject our methods first, so user can override them
            view_class.send(:include, Streamlined::Helper)
            @helper_overrides.each {|ho| view_class.send(:include, ho) }
            view_class.send(:include, master_helper_module)
          end
      end
      
      def initialize_with_streamlined_variables
          begin
            initialize_streamlined_values
            @managed_views = ['list', 'new', 'show', 'edit', 'quick_add', 'save_quick_add', 'update_filter_select']
            @managed_partials = ['list', 'form', 'popup', 'quick_add_errors']
            streamlined_logger.info("model NAME: #{model_name}")
            streamlined_logger.info("model: #{model.inspect}")
          rescue Exception => ex
            streamlined_logger.info("Could not instantiate controller: #{self.class.name}")
            raise ex
          end
      end
      alias_method_chain :initialize, :streamlined_variables
    end
  end
    
  def model_name 
    @custom_model_name || nil
  end
  
  def render_filters
    @render_filters ||= {}
  end

  def streamlined_model(mod)
    @custom_model_name = mod.instance_of?(String) ? mod : mod.name
  end
  
  def render_filter(action, options)
    render_filters[action] = options
  end
  
end

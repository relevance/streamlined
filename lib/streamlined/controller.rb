# Streamlined
# (c) 2005-7 Relevance, LLC. (http://thinkrelevance.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlinedframework.org/
module Streamlined::Controller; end

require 'streamlined/controller/crud_methods'
require 'streamlined/controller/enumeration_methods'
require 'streamlined/controller/relationship_methods'
require 'streamlined/controller/render_methods'
require 'streamlined/controller/callbacks'
require 'streamlined/controller/quick_add_methods'
require 'streamlined/controller/filter_methods'
require 'streamlined/controller/options_methods'

module Streamlined::Controller::InstanceMethods
  include Streamlined::Controller::CrudMethods
  include Streamlined::Controller::EnumerationMethods
  include Streamlined::Controller::RenderMethods
  include Streamlined::Controller::Callbacks
  include Streamlined::Controller::RelationshipMethods
  include Streamlined::Controller::QuickAddMethods
  include Streamlined::Controller::FilterMethods
  include Streamlined::Controller::OptionsMethods
  
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
    self.instance_variable_get("@#{model_name.variableize}")
  end

  def instance=(value)
    self.instance_variable_set("@#{model_name.variableize}", value)
    @streamlined_item = value
  end
  
       
  private
  def initialize_with_streamlined_variables
    initialize_streamlined_values
    streamlined_logger.info("model NAME: #{model_name}")
    streamlined_logger.info("model: #{model.inspect}")
  end
  
  def initialize_request_context
    @streamlined_request_context = Streamlined::Context::RequestContext.new(params[:page_options])
  end
      
  def initialize_streamlined_values(mod_name = nil)
    @streamlined_controller_context = Streamlined::Context::ControllerContext.new
    @streamlined_controller_context.model_name = mod_name || self.class.model_name || Inflector.classify(self.class.controller_name)
    # TODO: why isn't this in the html head?
    @page_title = "Manage #{model_name.pluralize}"
  rescue Exception => ex
    streamlined_logger.info("Could not instantiate controller: #{self.class.name}")
    raise ex
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
    raise ArgumentError, "options[:helpers] is deprecated" if options[:helpers]
    class_eval do
      attr_reader :streamlined_controller_context, :streamlined_request_context
      attr_with_default(:breadcrumb_trail) {[]}
      helper_method :crud_context, :render_tabs, :render_partials, :instance, :breadcrumb_trail
      # delegated helpers do not appear as routable actions!
      def self.delegate_non_routable(*delegates_args)
        delegates *delegates_args
        delegates_args.each {|arg| hide_action(arg)}
      end
      delegate_non_routable(*Streamlined::Context::ControllerContext::DELEGATES)
      delegate_non_routable(*Streamlined::Context::RequestContext::DELEGATES)
      include Streamlined::Controller::InstanceMethods
      before_filter :initialize_request_context
      Dir["#{RAILS_ROOT}/app/streamlined/*.rb"].each do |name|
        Dependencies.depend_on name, true
      end
      # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
      verify :method => :post, :only => [ :destroy, :create, :update ],
            :redirect_to => { :action => :list }
      alias_method_chain :initialize, :streamlined_variables
    end
  end
  
  def model_name
    @custom_model_name || nil
  end
  
  def streamlined_model(mod)
    @custom_model_name = mod.instance_of?(String) ? mod : mod.name
  end
  
  def filters
    @filters ||= {}
  end
  
  def callbacks
    @callbacks ||= {}
  end
  
  def render_filters
    filters[:render] ||= {}
  end
    
  def render_filter(action, options)
    render_filters[action] = options
  end
  
  # Declare a method or proc to be called after the instance is created (and populated with params) but before save is called
  # If the callback returns false, save will not be called.
  def before_streamlined_create(callback)
    unless callback.is_a?(Proc) || callback.is_a?(Symbol) 
      raise ArgumentError, "Invalid options for db_action_filter - must pass either a Proc or a Symbol, you gave [#{callback.inspect}]"
    end
    callbacks[:before_create] = callback
  end

  # Declare a method or proc to be called after the instance is updated (and populated with params) but before save is called
  # If the callback returns false, save will not be called.  
  def before_streamlined_update(callback)
    unless callback.is_a?(Proc) || callback.is_a?(Symbol) 
      raise ArgumentError, "Invalid options for db_action_filter - must pass either a Proc or a Symbol, you gave [#{callback.inspect}]"
    end
    callbacks[:before_update] = callback
  end
  
  def count_or_find_options(options=nil)
    return @count_or_find_options || {} unless options
    @count_or_find_options = options
  end
end

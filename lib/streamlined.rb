module Streamlined
  class Error < RuntimeError; end
  
  def self.ui_for(model, &blk)
    ui = Streamlined::Registry.ui_for(model)
    ui.instance_eval(&blk) if block_given?
    ui
  end
end

require 'streamlined/context'
require 'streamlined/render_methods'
require 'streamlined/breadcrumb'
require 'streamlined/column'
require 'streamlined/ui'
require 'streamlined/controller'
require 'streamlined/helper'
require 'streamlined/registry'

# have to do this to provide acts_as_streamlined
ActionController::Base.class_eval do 
  extend Streamlined::Controller::ClassMethods
end

module Streamlined
  class Error < RuntimeError; end
end

require 'streamlined/context'
require 'streamlined/render_methods'
require 'streamlined/column'
require 'streamlined/ui'
require 'streamlined/controller'
require 'streamlined/helper'

# have to do this to provide acts_as_streamlined
ActionController::Base.class_eval do 
  extend Streamlined::Controller::ClassMethods
end

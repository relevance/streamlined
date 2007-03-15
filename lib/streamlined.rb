module Streamlined
  class Error < RuntimeError; end
end

require 'streamlined/context'
require 'streamlined/render_methods'
require 'streamlined/column'
require 'streamlined/ui'
require 'streamlined/controller'
require 'streamlined/helper'

ActionController::Base.class_eval do 
  include Streamlined::Controller
end


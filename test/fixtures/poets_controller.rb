require "#{RAILS_ROOT}/app/controllers/application"
class PoetsController < ApplicationController
	acts_as_streamlined
	layout "streamlined"  # need this to test markup in the layouts
end  

# TODO: this should go away once the UI class is optional
class PoetUI < Streamlined::UI
end

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end


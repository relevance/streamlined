class PeopleController < ApplicationController
	acts_as_streamlined
end  

# TODO: this should go away once the UI class is optional
class PersonUI < Streamlined::UI
end

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end


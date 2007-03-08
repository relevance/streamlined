# begin
begin
  Dependencies.load_paths.unshift("#{RAILS_ROOT}/app/streamlined")
rescue
  # nothing
end

require 'implants/module'
require 'implants/hash_init'
require 'implants/csv'
require 'page_options'
require 'active_record_extensions'
require 'streamlined_relationships'
require 'streamlined_ui'
require 'streamlined/controller'
require 'streamlined/helper'

ActionController::Base.class_eval do 
  include Streamlined::Controller
end

ActionView::Base.send :include, Streamlined::Helper
  
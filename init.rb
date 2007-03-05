raise "Must have a RAILS_ROOT" unless RAILS_ROOT
STREAMLINED_ROOT = File.dirname(__FILE__)
# STREAMLINED_GENERIC_VIEW_ROOT must be RELATIVE (!) to RAILS_ROOT/app/views
# because that is how Rails looks up templates!
STREAMLINED_GENERIC_VIEW_ROOT = 
  File.join(Pathname.new(STREAMLINED_ROOT).relative_path_from(Pathname.new(RAILS_ROOT+"/app/views")).to_s,
                         "/templates/generic_views")
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
require 'streamlined_controller'
require 'streamlined_helper'

ActionController::Base.class_eval do 
  include StreamlinedController
end

ActionView::Base.send :include, StreamlinedHelper
  
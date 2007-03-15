# begin
begin
  Dependencies.load_paths.unshift("#{RAILS_ROOT}/app/streamlined")
rescue
  # nothing
end

require 'relevance/delegates'
require 'implants/module'
require 'implants/hash_init'
require 'implants/csv'
require 'active_record_extensions'
require 'streamlined'
  
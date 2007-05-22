if defined?(Dependencies)
  Dependencies.load_paths.unshift("#{RAILS_ROOT}/app/streamlined")
end

require 'relevance/string_additions'
require 'relevance/module_additions'
require 'implants/module'
require 'implants/hash_init'
require 'implants/csv'
require 'relevance/active_record_extensions'
require 'streamlined'

# Rails 1.2.2 bug workaround
# See http://www.pdatasolutions.com/blog/archive/2007/02/mime_type_csv_bug_in_rails_122.html
Mime::SET << Mime::CSV unless Mime::SET.include?(Mime::CSV)

  
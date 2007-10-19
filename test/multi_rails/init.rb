if Object.const_defined?("RAILS_ENV") && RAILS_ENV == "test"
  require File.expand_path(File.join(File.dirname(__FILE__), "lib/multi_rails"))
  MultiRails::require_rails
end
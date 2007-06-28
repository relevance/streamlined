gem 'activerecord'
require 'active_record'

ActiveRecord::Base.configurations = YAML.load_file 'config/database.yml'
ActiveRecord::Base.establish_connection 'streamlined_unittest'
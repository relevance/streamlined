gem 'activerecord'
require 'active_record'
AR_BASE = $:.grep(/activerecord/).first.sub(/(activerecord.*?\/).*/,"\\1")

ActiveRecord::Base.configurations = {
  'streamlined_unittest' => {
    :adapter => 'mysql',
    :username => 'root',
    :database => 'streamlined_unittest'
  },
}
ActiveRecord::Base.establish_connection 'streamlined_unittest'

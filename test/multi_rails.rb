# Handles testing Streamlined against multiple rails version, or defaults to 1_2_3
# You must use gems to install rails 2_0_0 PR if you want to test against that
# To specifically set the rails version, set the environment variable STREAMLINED_RAILS_VERSION.
# Valid versions are:
#
#  "1_2_3" (the default)
#  "2_0_0_PR"
class MultiRails
  
  def self.load_1_2_3
    gem 'rails', "1.2.3"  
    require 'active_record'
    require 'action_controller'
    require 'action_controller/test_process'
    require 'active_support'
  rescue LoadError
    puts "\n\nYou must gem install the 1_2_3 version of Rails for the default Streamlined test suite.\n\n"
    raise
  end
  
  def self.load_2_0_0_PR
    # gem 'rails', "1.2.4.7794"
    gem 'rails', "1.2.5.7919"
    require 'active_record'
    require 'action_controller'
    require 'action_controller/test_process'
    require 'active_support'
  end
  
  def self.load(rails_version)
    rails_version ||= "1_2_3"
    self.send("load_#{rails_version}")
  end
end

MultiRails.load(ENV["STREAMLINED_RAILS_VERSION"])
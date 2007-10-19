require 'rubygems'
require 'rake'
require 'rake/testtask'
require File.expand_path(File.join(File.dirname(__FILE__), "/../lib/multi_rails"))

class Rake::Task
  attr_accessor :already_invoked
end

namespace :test do
  namespace :multi_rails do

    desc "Run against all versions of Rails"
    task :all do
      MultiRails::Loader.all_rails_versions.each_with_index do |version, index|
        puts version
        reset_rake_task unless index == 0
        Rake::Task[:test].invoke
      end
    end
    
    def reset_rake_task
      Rake::Task[:test].already_invoked = false
      Rake::Task[:test].prerequisites.each {|p| Rake::Task[p].already_invoked = false}
    end
  end
end


# desc "Run all tests against all versions of Rails multirails supports."
# task :all_rails do
#   puts "running tests against Rails 123"
#   ENV["STREAMLINED_RAILS_VERSION"] = "1_2_3"
#   Rake::Task[:test].invoke
#   Rake::Task[:test].already_invoked = false
#   Rake::Task[:test].prerequisites.each {|p| Rake::Task[p].already_invoked = false}
#   puts "running tests against Rails 2_0_0_PR"
#   ENV["STREAMLINED_RAILS_VERSION"] = "2_0_0_PR"
#   Rake::Task[:test].invoke 
# end

require 'rubygems'
require 'rake'
require 'rake/testtask'
require File.expand_path(File.join(File.dirname(__FILE__), "/../lib/multi_rails"))

class Rake::Task
  attr_accessor :already_invoked
end

namespace :test do
  namespace :multi_rails do

  BAR = "=" * 80
  
    desc "Run against all versions of Rails"
    task :all do
      MultiRails::Loader.all_rails_versions.each_with_index do |version, index|
        puts "\n#{BAR}\nRunning tests against version: #{version}\n#{BAR}"
        silence_warnings { ENV["RAILS_VERSION"] = version }
        reset_rake_task unless index == 0
        Rake::Task[:test].invoke
      end
    end
    
    desc "Run against one verison of Rails specified as 'rails_version'"
    task :one do
      Rake::Task[:test].invoke
    end
    
    def reset_rake_task
      Rake::Task[:test].already_invoked = false
      Rake::Task[:test].prerequisites.each {|p| Rake::Task[p].already_invoked = false}
    end
  end
end
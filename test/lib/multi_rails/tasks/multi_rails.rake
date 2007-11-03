require 'rubygems'
require 'rake'
require 'rake/testtask'
require File.expand_path(File.join(File.dirname(__FILE__), "/../lib/multi_rails"))

# Enable overriding the already invoked flag of a Rake task
class Rake::Task
  attr_accessor :already_invoked
end

namespace :test do
  namespace :multi_rails do

    desc "Run against all installed versions of Rails.  Local versions found: [#{MultiRails::Loader.all_rails_versions.to_sentence}]."
    task :all do
      begin
        MultiRails::Loader.all_rails_versions.each_with_index do |version, index|
          silence_warnings { ENV["MULTIRAILS_RAILS_VERSION"] = version }
          write_rails_gem_version_file(version) if within_rails_app?
          print_rails_version
          reset_test_tasks unless index == 0
          Rake::Task[:test].invoke
        end
      ensure
        clean_up_rails_gem_version_file
      end
    end
    
    desc "Run against one verison of Rails specified as 'MULTIRAILS_RAILS_VERSION' - for example 'rake test:multi_rails:one MULTIRAILS_RAILS_VERSION=1.2.3'"
    task :one do
      print_rails_version
      Rake::Task[:test].invoke
    end
    
    desc "Run against the most recent version of Rails installed.  Most recent found: [#{MultiRails::Loader.latest_version}]."
    task :latest do
      ENV["MULTIRAILS_RAILS_VERSION"] = MultiRails::Loader.latest_version
      print_rails_version
      Rake::Task[:test].invoke
    end
    
    def within_rails_app?
      Object.const_defined?("Rails") && Object.const_defined?("RAILS_ROOT")
    end
    
    def rails_gem_version_file
      "#{RAILS_ROOT}/config/rails_version.rb"
    end
    
    # Clean up the temp file we need for 
    def clean_up_rails_gem_version_file
      FileUtils.rm(rails_gem_version_file) if within_rails_app? && File.exist?(rails_gem_version_file)
    end
    
    # This is a hack we have to do to properly set the RAILS_GEM_VERSION before environment.rb and boot.rb run
    def write_rails_gem_version_file(version)
      `echo RAILS_GEM_VERSION=\\"#{version}\\" > #{rails_gem_version_file}`
    end

    BAR = "=" * 80
    def print_rails_version
      puts "\n#{BAR}\nRequiring rails version: #{MultiRails::Config.version_lookup}\n#{BAR}"
    end
    
    # Need to hack the Rake test task a bit, otherwise it will only run once and never repeat.
    def reset_test_tasks
      ["test", "test:units", "test:functionals", "test:integration"].each do |name| 
        if Rake::Task.task_defined?(name)
          Rake::Task[name].already_invoked = false
          Rake::Task[name].prerequisites.each {|p| Rake::Task[p].already_invoked = false}
        end
      end
    end
    
  end
end
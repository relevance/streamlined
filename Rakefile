require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'test/ar_helper'

def db_config
  ActiveRecord::Base.configurations['streamlined_unittest']
end

# allows us to re-run the tests
class Rake::Task
  attr_accessor :already_invoked, :prerequisites
end

task :test => ['test:units', 'test:functionals']

desc 'Default: run tests.'
task :default => ['test']

desc 'Default task for CruiseControl'
task :cruise => ['test', 'test:flog']

desc 'Test for Flog'
namespace :test do
  task :flog do
    threshold = (ENV['FLOG_THRESHOLD'] || 120).to_i
    result = IO.popen('flog lib 2>/dev/null | grep "(" | grep -v "main#none" | grep -v "AccountController#login" | head -n 1').readlines.join('')
    result =~ /\((.*)\)/
    flog = $1.to_i
    result =~ /^(.*):/
    method = $1
    if flog > threshold
      raise "FLOG failed for #{method} with score of #{flog} (threshold is #{threshold})."
    end  
    puts "FLOG passed, with highest score being #{flog} for #{method}."
  end
  
  desc "Run all tests against all versions of Rails multirails supports."
  task :all_rails do
    puts "running tests against Rails 123"
    ENV["STREAMLINED_RAILS_VERSION"] = "1_2_3"
    Rake::Task[:test].invoke
    Rake::Task[:test].already_invoked = false
    Rake::Task[:test].prerequisites.each {|p| Rake::Task[p].already_invoked = false}
    puts "running tests against Rails 2_0_0_PR"
    ENV["STREAMLINED_RAILS_VERSION"] = "2_0_0_PR"
    Rake::Task[:test].invoke 
  end
  
end


namespace :test do
  desc 'Unit test the streamlined plugin.'
  Rake::TestTask.new(:units) do |t|
    t.libs << 'test'
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true
  end

  desc 'Functional test the streamlined plugin.'
  Rake::TestTask.new(:functionals) do |t|
    t.libs << 'test'
    t.pattern = 'test/functional/**/*_test.rb'
    t.verbose = true
  end
  
  require 'test/javascripts/jstest'
  desc "Runs all the JavaScript unit tests and collects the results"
  JavaScriptTestTask.new(:javascripts) do |t|
    tests_to_run     = ENV['TESTS']    && ENV['TESTS'].split(',')
    browsers_to_test = ENV['BROWSERS'] && ENV['BROWSERS'].split(',')

    t.mount("/test/javascripts")
    t.mount("/files")

    Dir["test/javascripts/*.html"].sort.each do |test_file|
      test_file = "/#{test_file}"
      test_name = test_file[/.*\/(.+?)\.html/, 1]
      t.run(test_file) unless tests_to_run && !tests_to_run.include?(test_name)
    end

    %w( safari firefox ie konqueror ).each do |browser|
      t.browser(browser.to_sym) unless browsers_to_test && !browsers_to_test.include?(browser)
    end
  end
  
  
  
  desc 'Build the MySQL test databases'
  task :build_mysql_databases do
    %x( mysqladmin -u #{db_config['username']} create #{db_config['database']} )
    # %x( mysql -u #{db_config['username']} -e "grant all on #{db_config['database']}.* to #{db_config['username']}@localhost" )
    %x( mysql -u #{db_config['username']} #{db_config['database']} < 'test/db/mysql.sql' )
  end
  
  desc 'Drop the MySQL test databases'
  task :drop_mysql_databases do
    %x( mysqladmin -u #{db_config['username']} -f drop #{db_config['database']} )
  end
  
  desc 'Rebuild the MySQL test databases'
  task :rebuild_mysql_databases => ['test:drop_mysql_databases', 'test:build_mysql_databases']
  
end

desc 'Generate documentation for the streamlined plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'RelevanceExtensions'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rcov/rcovtask'
namespace :test do
  namespace :coverage do
    namespace :all do
      desc 'Full coverage test'
      task :test do
        rm_f "coverage"
        rm_f "coverage.data"
        rcov = "rcov --sort coverage --rails --aggregate coverage.data --text-summary -Ilib"
        # this is painful, but the rake passthrough isn't working
        system("#{rcov} --no-html test/unit/*_test.rb")
        system("#{rcov} --no-html test/unit/*/*_test.rb")
        system("#{rcov} --no-html test/unit/*/*/*_test.rb")
        system("#{rcov} --no-html test/functional/*_test.rb")  
        system("#{rcov} --no-html test/functional/*/*_test.rb")  
        system("#{rcov} --html test/functional/*/*/*_test.rb")
      end
    end
    task :report => "all:test" do
      system("open coverage/index.html") if PLATFORM['darwin']
    end
  end
end

namespace :log do
  desc "Truncates all *.log files in log/ to zero bytes"
  task :clear do
    FileList["log/*.log"].each do |log_file|
      f = File.open(log_file, "w")
      f.close
    end
  end
end


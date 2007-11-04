require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'test/lib/ar_helper'
load 'test/lib/multi_rails/tasks/multi_rails.rake'
load 'tasks/rcov.rake'

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
  
  file 'test/javascripts/crosscheck/crosscheck.jar' do
    puts "You must install test/javascripts/crosscheck/crosscheck.jar (http://www.thefrontside.net/crosscheck) to run the JavaScript tests"
  end
  
  desc "Runs all the JavaScript unit tests and collects the results"
  task :javascripts => "test/javascripts/crosscheck/crosscheck.jar" do
    if File.exists?('test/javascripts/crosscheck/crosscheck.jar')
      Dir.chdir("test/javascripts") do
        raise "Test failures" unless system("java -jar crosscheck/crosscheck.jar -hosts=ie-6 test.js")
      end
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

namespace :log do
  desc "Truncates all *.log files in log/ to zero bytes"
  task :clear do
    FileList["log/*.log"].each do |log_file|
      f = File.open(log_file, "w")
      f.close
    end
  end
end


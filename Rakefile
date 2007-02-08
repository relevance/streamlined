require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'test/ar_helper'

task :test => ['test:units', 'test:functionals']

desc 'Default: run tests.'
task :default => ['test']

namespace :test do
  desc 'Unit test the streamlined plugin.'
  Rake::TestTask.new('units') do |t|
    t.libs << 'test'
    t.pattern = 'test/unit/*_test.rb'
    t.verbose = true
  end

  desc 'Functional test the streamlined plugin.'
  Rake::TestTask.new('functionals') do |t|
    t.libs << 'test'
    t.pattern = 'test/functional/*_test.rb'
    t.verbose = true
  end
  
  task 'test:functionals'

  # Use Rails test database so we don't need to manage our own
  desc 'Build the MySQL test databases'
  task :build_mysql_databases do 
    %x( mysqladmin -u root create streamlined_unittest )
    # %x( mysql -u root -e "grant all on streamlined_unittest.* to root@localhost" )
    %x( mysql -u root streamlined_unittest < 'test/db/mysql.sql' )
  end
  
  desc 'Drop the MySQL test databases'
  task :drop_mysql_databases do 
    %x( mysqladmin -u root -f drop streamlined_unittest )
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

namespace 'rcov' do
  begin
    require 'rcov/rcovtask'
    Rcov::RcovTask.new do |t|
      t.name = 'test'
      t.libs << "test"
      t.test_files = FileList['test/**/*test.rb']   
      t.verbose = true
    end
  rescue LoadError                                  
    # ignore missing rcov
  end
end

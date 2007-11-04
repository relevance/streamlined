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
require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/multi_rails"))

describe "loader" do
  
  setup do
    never_really_require_rails
  end
  
  it "should fall back to a default verison to try" do
    stub_rails_requires
    MultiRails::Loader.any_instance.expects(:gem).with("rails", MultiRails::Config.default_rails_version)
    MultiRails::Loader.require_rails
  end
  
  it "should fail fast if we are missing a requested gem version" do
    e = lambda { MultiRails::Loader.require_rails("9.9.9") }.should.raise(MultiRailsError)
    e.message.should == "Cannot find gem for Rails version: '9.9.9'!\nInstall the missing gem with:\ngem install -v=9.9.9 rails"
  end
  
  it "should gem the specified version" do
    stub_rails_requires
    MultiRails::Loader.any_instance.expects(:gem).with("rails", "1.2.5").returns(true)
    MultiRails::Loader.require_rails("1.2.5")
  end
  
  it "should allow using a better name for weird gem version numbers, like 2.0.0 PR => 1.2.4.7794" do
    stub_rails_requires
    MultiRails::Loader.any_instance.expects(:gem).with("rails", MultiRails::Config.weird_versions["2.0.0.PR"]).returns(true)
    MultiRails::Loader.require_rails("2.0.0.PR")
  end

  it "should require the needed dependancies" do
    MultiRails::Loader.any_instance.stubs(:gem)
    MultiRails::Config.rails_requires.each do |file|
      MultiRails::Loader.any_instance.expects(:require).with(file)
    end
    MultiRails::Loader.require_rails
  end
  
  def stub_rails_requires
    MultiRails::Loader.any_instance.stubs(:require).returns(true)
  end
  
  def never_really_require_rails
    MultiRails::Loader.any_instance.expects(:require).never
  end
end

describe "finding all gems of rails available" do
  
  it "should search the gem cache for rails" do
    Gem::cache.expects(:search).with("rails").returns([])
    MultiRails::Loader.all_rails_versions
  end
  
  it "should return all Rails versions it finds sorted with the earliest versions first" do
    specs = [stub(:version => stub(:to_s => "1.2.4")), stub(:version => stub(:to_s => "1.2.3"))]
    Gem::cache.expects(:search).with("rails").returns(specs)
    MultiRails::Loader.all_rails_versions.should == ["1.2.3", "1.2.4"]
  end
  
end

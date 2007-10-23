require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails_test_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/multi_rails"))

describe "Version Lookup in config" do
  
  it "should use argument version if passed in " do
    MultiRails::Config.version_lookup("1.2.3").should == "1.2.3"
  end
  
  it "should use env var if set" do
    begin
      MultiRails::Loader.stubs(:all_rails_versions).returns(["1.2.99"])
      ENV["RAILS_VERSION"] = "1.2.99"
      MultiRails::Config.version_lookup.should == "1.2.99"
    ensure
      silence_warnings { ENV["RAILS_VERSION"] = nil }
    end
  end
  
  it "should raise if providing env var and we dont find a corresponding version" do
    begin
      ENV["RAILS_VERSION"] = "X.X.99"
      lambda { MultiRails::Config.version_lookup }.should.raise(MultiRailsError)
    ensure
      silence_warnings { ENV["RAILS_VERSION"] = nil }
    end
  end
  
  it "should use latest stable version if there is no argumnt or env var" do
    MultiRails::Config.version_lookup.should == MultiRails::Loader.latest_stable_version
  end
end

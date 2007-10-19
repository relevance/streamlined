require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/multi_rails"))

describe "Version Lookup in config" do
  
  it "should use argument version if passed in " do
    MultiRails::Config.version_lookup("1.2.3").should == "1.2.3"
  end
  
  it "should use env var if set" do
    begin
      ENV["RAILS_VERSION"] = "1.2.99"
      MultiRails::Config.version_lookup.should == "1.2.99"
    ensure
      silence_warnings { ENV["RAILS_VERSION"] = nil }
    end
  end
  
  it "should use default version if there is no argumnt or env var" do
    MultiRails::Config.version_lookup.should == MultiRails::Config.default_rails_version
  end
end

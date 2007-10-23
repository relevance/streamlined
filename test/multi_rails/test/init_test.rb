require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails_test_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/multi_rails"))

describe "Rails plugin init" do
  it "should do nothing if RAILS_ENV isn't set" do
    MultiRails.expects(:gem_and_require_rails).never
    load File.expand_path(File.join(File.dirname(__FILE__), "../init.rb"))
  end
  
  it "should only do anything in Test environment" do
    MultiRails.expects(:gem_and_require_rails).never
    load File.expand_path(File.join(File.dirname(__FILE__), "../init.rb"))
  end
  
  it "should require rails in Test environment" do
    silence_warnings do 
      begin
        orig_rails_env = Object.const_defined?("RAILS_ENV") ? Object.const_get("RAILS_ENV") : nil
        Object.const_set("RAILS_ENV", "test")
        MultiRails.expects(:gem_and_require_rails).once
        load File.expand_path(File.join(File.dirname(__FILE__), "../init.rb"))
      ensure
        Object.const_set("RAILS_ENV", orig_rails_env)
      end
    end
  end
  
end
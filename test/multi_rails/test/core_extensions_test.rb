require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "../lib/multi_rails"))

describe "core extensions" do
  it "should extend Kernel" do
    Kernel.should.respond_to? :silence_warnings
  end
end
